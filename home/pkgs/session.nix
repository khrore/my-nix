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
  isLinuxDesktop = mylib.isLinux system && isDisplay;
  # Reuse Zed's pinned upstream asset; keep only the variant we actually use.
  zedGruvbox =
    pkgs-unstable.runCommand "zed-gruvbox-dark.json"
      {
        nativeBuildInputs = [ pkgs-unstable.jq ];
      }
      ''
        jq '.themes |= map(select(.name == "Gruvbox Dark"))' \
          ${pkgs-unstable.zed-editor.src}/assets/themes/gruvbox/gruvbox.json > "$out"
      '';
  themeSeeds = {
    ".config/zed/themes/linux-desktop.json" = ../theme-defaults/zed.json;
    ".config/zellij/themes/linux-desktop.kdl" = ../theme-defaults/zellij.kdl;
  }
  // lib.optionalAttrs (mylib.isLinux system) {
    ".config/yazi/flavors/linux-desktop.yazi/flavor.toml" = ../theme-defaults/yazi.toml;
    ".config/yazi/flavors/linux-desktop.yazi/tmtheme.xml" = ../theme-defaults/yazi.tmtheme;
  };
  fileManager = pkgs-unstable.org-freedesktop-filemanager1-common;
  fileManagerLauncher = pkgs-unstable.writeShellScript "file-manager-yazi" ''
    export PATH=${
      lib.makeBinPath [
        pkgs-unstable.yazi
        pkgs-unstable.coreutils
      ]
    }:"$PATH"
    export TERMCMD=${pkgs-unstable.xdg-terminal-exec}/bin/xdg-terminal-exec
    exec ${fileManager}/share/org.freedesktop.FileManager1.common/yazi-wrapper.sh "$@"
  '';

  sessionPkgs =
    with pkgs-unstable;
    lib.optionals isLinuxDesktop [
      # Graphical session packages
      alacritty
      elephant
      fastfetch
      fcitx5
      fcitx5-gtk
      libsForQt5.fcitx5-qt
      gum
      gpu-screen-recorder
      grim
      hyprsunset
      mako
      mise
      pamixer
      polkit_gnome
      satty
      signal-desktop
      slurp
      swaybg
      swayosd
      uwsm
      walker
      wiremix
      xdg-terminal-exec
      fileManager
      v4l-utils
      catppuccin-cursors.mochaDark

      # Tools referenced by session bindings and helpers
      dconf
      qt6Packages.qt6ct
      (writeShellScriptBin "theme-config-python" ''
        exec ${
          python3.withPackages (ps: [
            ps.tomlkit
            ps.json5
          ])
        }/bin/python3 "$@"
      '')
      netcat-openbsd
      pywalfox-native
      pam_u2f
      xournalpp
    ];
in
{
  home.packages = sessionPkgs;

  # Generated themes are mutable app state, not files owned by the dotfile linker.
  home.activation.seedDesktopThemes = lib.mkIf isDisplay (
    lib.hm.dag.entryAfter [ "linkDotfiles" ] (
      lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          relative: source:
          let
            target = lib.escapeShellArg "${config.home.homeDirectory}/${relative}";
          in
          ''
            if [[ ! -e ${target} && ! -L ${target} ]]; then
              run ${pkgs-unstable.coreutils}/bin/install -D -m 600 ${source} ${target}
            fi
          ''
        ) themeSeeds
      )
    )
  );

  xdg.dataFile."linux-desktop/default/zed-gruvbox.json" = lib.mkIf isLinuxDesktop {
    source = zedGruvbox;
  };

  # Publish a dark fallback even before the first desktop palette is selected.
  dconf.settings = lib.mkIf isLinuxDesktop {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
    };
  };
  qt = lib.mkIf isLinuxDesktop {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "Fusion";
  };

  xdg.configFile."org.freedesktop.FileManager1.common/config" = lib.mkIf isLinuxDesktop {
    text = "cmd=${fileManagerLauncher}\n";
  };

  # Prefer Yazi over other activatable file managers for browser "Show in folder".
  xdg.dataFile."dbus-1/services/org.freedesktop.FileManager1.service" = lib.mkIf isLinuxDesktop {
    source = "${fileManager}/share/dbus-1/services/org.freedesktop.FileManager1.service";
  };
}
