{
  config,
  lib,
  pkgs-unstable,
  mylib,
  system,
  isDisplay,
  ...
}:
let
  pkgs = pkgs-unstable;
  isDarwin = mylib.isDarwin system;
  root = "${config.home.homeDirectory}/.local/share/desktop";
  python = pkgs.python3.withPackages (ps: [
    ps.tomlkit
    ps.json5
  ]);
  themePython = pkgs.writeShellScriptBin "theme-config-python" ''
    exec ${python}/bin/python3 "$@"
  '';
  runtime = lib.makeBinPath [
    pkgs.bash
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnused
    pkgs.gnugrep
    pkgs.jq
    themePython
  ];
  # Fixed entry points also work from AeroSpace's non-interactive environment.
  commandNames = [
    "theme-set"
    "theme-list"
    "theme-current"
    "theme-refresh"
    "theme-set-templates"
    "theme-set-zed"
    "theme-set-zellij"
    "theme-set-yazi"
    "theme-set-codex"
    "restart-terminal"
    "restart-btop"
    "hook"
  ]
  ++ lib.optionals isDarwin [
    "theme-pick"
    "theme-bg-set"
    "theme-bg-next"
    "theme-set-macos"
  ];
  commands = pkgs.symlinkJoin {
    name = "desktop-theme-commands";
    paths = map (
      name:
      pkgs.writeShellScriptBin name ''
        export DESKTOP_ROOT="''${DESKTOP_ROOT:-''${LINUX_SESSION_ROOT:-${root}}}"
        export LINUX_SESSION_ROOT="$DESKTOP_ROOT"
        export PATH="${runtime}:$DESKTOP_ROOT/bin:${
          lib.makeBinPath [
            pkgs.yazi
            pkgs.zellij
          ]
        }:$HOME/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
        exec ${
          if
            lib.elem name [
              "theme-pick"
              "theme-bg-set"
              "theme-bg-next"
              "theme-set-zed"
              "theme-set-zellij"
              "theme-set-yazi"
              "theme-set-codex"
            ]
          then
            "${python}/bin/python3"
          else
            "${pkgs.bash}/bin/bash"
        } "$DESKTOP_ROOT/bin/${name}" "$@"
      ''
    ) commandNames;
  };
  desktopLauncher = pkgs.writeShellScriptBin "mac-desktop" ''
    export PATH="${commands}/bin:${runtime}:${
      lib.makeBinPath [
        pkgs.yazi
        pkgs.zellij
      ]
    }:$HOME/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    case "''${1:-}" in
      terminal) exec /usr/bin/open -a Ghostty ;;
      browser) exec /usr/bin/open -a Zen ;;
      editor) exec /usr/bin/open -a Zed ;;
      music) exec /usr/bin/open -a Spotify ;;
      notes) exec /usr/bin/open -a Obsidian ;;
      passwords) exec /usr/bin/open -a Bitwarden ;;
      files) exec /usr/bin/open -na Ghostty --env "PATH=$PATH" --args -e ${pkgs.yazi}/bin/yazi ;;
      theme) exec ${commands}/bin/theme-pick ;;
      wallpaper) exec ${commands}/bin/theme-bg-next ;;
      *) echo "Unknown desktop action: ''${1:-}" >&2; exit 1 ;;
    esac
  '';
  zedGruvbox = pkgs.runCommand "zed-gruvbox-dark.json" { nativeBuildInputs = [ pkgs.jq ]; } ''
    jq '.themes |= map(select(.name == "Gruvbox Dark"))' \
      ${pkgs.zed-editor.src}/assets/themes/gruvbox/gruvbox.json > "$out"
  '';
  themeSeeds = {
    ".config/zed/themes/desktop.json" = ../theme-defaults/zed.json;
    ".config/zellij/themes/desktop.kdl" = ../theme-defaults/zellij.kdl;
    ".config/yazi/flavors/desktop.yazi/flavor.toml" = ../theme-defaults/yazi.toml;
    ".config/yazi/flavors/desktop.yazi/tmtheme.xml" = ../theme-defaults/yazi.tmtheme;
  };
in
lib.mkIf isDisplay {
  home.packages = [
    commands
    themePython
    pkgs.bash
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnused
    pkgs.gnugrep
  ];
  home.file.".local/bin/mac-desktop" = lib.mkIf isDarwin {
    source = "${desktopLauncher}/bin/mac-desktop";
  };
  xdg.dataFile."desktop/default/zed-gruvbox.json".source = zedGruvbox;

  # Mutable generated themes are seeded once, never owned by the dotfile linker.
  home.activation.seedDesktopThemes = lib.hm.dag.entryAfter [ "linkDotfiles" ] (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        relative: source:
        let
          target = lib.escapeShellArg "${config.home.homeDirectory}/${relative}";
        in
        ''
          if [[ ! -e ${target} && ! -L ${target} ]]; then
            run ${pkgs.coreutils}/bin/install -D -m 600 ${source} ${target}
          fi
        ''
      ) themeSeeds
    )
  );
}
