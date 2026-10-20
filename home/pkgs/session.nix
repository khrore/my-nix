{
  lib,
  pkgs-unstable,
  mylib,
  system,
  isDisplay,
  ...
}:
let
  isLinuxDesktop = mylib.isLinux system && isDisplay;
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

  xdg.configFile."org.freedesktop.FileManager1.common/config" = lib.mkIf isLinuxDesktop {
    text = "cmd=${fileManagerLauncher}\n";
  };

  # Prefer Yazi over other activatable file managers for browser "Show in folder".
  xdg.dataFile."dbus-1/services/org.freedesktop.FileManager1.service" = lib.mkIf isLinuxDesktop {
    source = "${fileManager}/share/dbus-1/services/org.freedesktop.FileManager1.service";
  };
}
