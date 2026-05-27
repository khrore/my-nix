{
  lib,
  pkgs-unstable,
  mylib,
  system,
  isDisplay,
  ...
}:
let
  linuxOmarchyPkgs =
    with pkgs-unstable;
    lib.optionals (mylib.isLinux system && isDisplay) [
      # Omarchy desktop/runtime layer
      alacritty
      bluetui
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
      upower
      v4l-utils
      catppuccin-cursors.mochaDark

      # Omarchy workflow tools referenced by bindings and helpers
      netcat-openbsd
      pam_u2f
      xournalpp
    ];
in
{
  home.packages = linuxOmarchyPkgs;
}
