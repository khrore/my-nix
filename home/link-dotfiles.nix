{
  config,
  pkgs,
  mylib,
  system,
  ...
}:

let
  platform =
    if mylib.isDarwin system then
      "darwin"
    else if mylib.isLinux system then
      "nixos"
    else
      "common";
  homeDir = config.home.homeDirectory;

  runtimeLinkingLogic = ''
    find_repo_root_from_dir() {
      local start_dir current_dir

      start_dir="$1"
      [ -n "$start_dir" ] || return 1
      [ -d "$start_dir" ] || return 1

      current_dir="$(cd "$start_dir" && pwd)"

      while [ "$current_dir" != "/" ]; do
        if [ -d "$current_dir/dotfiles" ] && [ -f "$current_dir/flake.nix" ]; then
          printf '%s\n' "$current_dir"
          return 0
        fi
        current_dir="$(dirname "$current_dir")"
      done

      if [ -d "/dotfiles" ] && [ -f "/flake.nix" ]; then
        printf '/\n'
        return 0
      fi

      return 1
    }

    find_repo_root() {
      local candidate

      for candidate in \
        "''${NIXOS_CONFIG:-}" \
        "''${PWD:-}" \
        "''${XDG_CONFIG_HOME:-${homeDir}/.config}" \
        "${homeDir}"
      do
        if candidate="$(find_repo_root_from_dir "$candidate" 2>/dev/null)"; then
          printf '%s\n' "$candidate"
          return 0
        fi
      done

      while IFS= read -r candidate; do
        candidate="$(dirname "$candidate")"
        if [ -d "$candidate/dotfiles" ] && [ -f "$candidate/flake.nix" ]; then
          printf '%s\n' "$candidate"
          return 0
        fi
      done < <(find "${homeDir}" -maxdepth 3 -name flake.nix -type f 2>/dev/null)

      return 1
    }

    link_dotfiles_runtime() {
      local repo_root dotfiles_root common_dir platform_dir agents_skills codex_skills
      local skill_source skill_name skill_target codex_skills_link
      local rel source target prefix source_dir target_prefix target_rel layer stale_link
      declare -A sources=()
      local -a layers=()

      repo_root="$(find_repo_root || true)"
      if [ -z "$repo_root" ]; then
        echo "Dotfiles repo not found. Set NIXOS_CONFIG_ROOT to override automatic discovery."
        return 0
      fi

      dotfiles_root="$repo_root/dotfiles"
      common_dir="$dotfiles_root/common"
      platform_dir="$dotfiles_root/${platform}"

      if [ -d "$common_dir" ]; then
        layers+=("$common_dir:")
      fi

      if [ -d "$platform_dir" ]; then
        layers+=("$platform_dir:")
      fi

      if [ "''${#layers[@]}" -eq 0 ]; then
        echo "No dotfiles found to link."
        return 0
      fi

      for layer in "''${layers[@]}"; do
        source_dir="''${layer%%:*}"
        target_prefix="''${layer#*:}"

        while IFS= read -r -d "" file; do
          prefix="$source_dir/"
          rel="''${file#"$prefix"}"
          if [ -n "$target_prefix" ]; then
            target_rel="$target_prefix/$rel"
          else
            target_rel="$rel"
          fi
          sources["$target_rel"]="$file"
        done < <(find "$source_dir" -type f ! -name ".gitkeep" -print0)
      done

      echo "Processing ''${#sources[@]} dotfile entries from $repo_root..."

      while IFS= read -r target_rel; do
        source="''${sources["$target_rel"]}"
        target="$HOME/$target_rel"

        mkdir -p "$(dirname "$target")"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
          echo "Warning: $target exists and is not a symlink, skipping..."
        else
          ln -snf "$source" "$target"
          echo "✓ Linked $target_rel"
        fi
      done < <(printf '%s\n' "''${!sources[@]}" | LC_ALL=C sort)

      while IFS= read -r stale_link; do
        source="$(readlink "$stale_link" 2>/dev/null || true)"
        case "$source" in
          "$repo_root"/dotfiles/*|"$repo_root"/omarchy/config/*)
            rm -f "$stale_link"
            echo "✓ Removed stale link ''${stale_link#$HOME/}"
            ;;
        esac
      done < <(find "$HOME" -xtype l 2>/dev/null)

      agents_skills="$HOME/.agents/skills"
      codex_skills="$HOME/.codex/skills"

      if [ -d "$agents_skills" ]; then
        if [ -L "$codex_skills" ]; then
          codex_skills_link="$(readlink "$codex_skills" 2>/dev/null || true)"
          if [ "$codex_skills_link" = "$agents_skills" ]; then
            rm -f "$codex_skills"
          else
            echo "Warning: $codex_skills is a symlink, skipping custom skill links..."
            return 0
          fi
        fi

        if [ -e "$codex_skills" ] && [ ! -d "$codex_skills" ]; then
          echo "Warning: $codex_skills exists and is not a directory, skipping custom skill links..."
        else
          mkdir -p "$codex_skills"

          while IFS= read -r -d "" skill_source; do
            skill_name="$(basename "$skill_source")"
            if [ "$skill_name" = ".system" ]; then
              continue
            fi

            skill_target="$codex_skills/$skill_name"
            if [ -e "$skill_target" ] && [ ! -L "$skill_target" ]; then
              echo "Warning: $skill_target exists and is not a symlink, skipping..."
            else
              ln -snf "$skill_source" "$skill_target"
              echo "✓ Linked .codex/skills/$skill_name -> .agents/skills/$skill_name"
            fi
          done < <(find "$agents_skills" -mindepth 1 -maxdepth 1 -type d -print0)
        fi
      fi
    }
  '';

  linkScript = pkgs.writeShellScriptBin "link-dotfiles" ''
    set -e

    echo "Linking dotfiles for platform: ${platform}"
    ${runtimeLinkingLogic}
    link_dotfiles_runtime

    echo "Done! Dotfiles linked successfully."
  '';
in
{
  home.packages = [ linkScript ];

  home.activation.linkDotfiles = {
    after = [ "linkGeneration" ];
    before = [ ];
    data = ''
      ${runtimeLinkingLogic}
      link_dotfiles_runtime
    '';
  };
}
