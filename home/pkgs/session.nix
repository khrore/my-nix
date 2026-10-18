{
  lib,
  pkgs-unstable,
  mylib,
  system,
  isDisplay,
  ...
}:
let
  sessionPkgs =
    with pkgs-unstable;
    lib.optionals (mylib.isLinux system && isDisplay) [
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
      v4l-utils
      catppuccin-cursors.mochaDark

      # Tools referenced by session bindings and helpers
      netcat-openbsd
      pywalfox-native
      pam_u2f
      xournalpp
    ];
in
{
  home.packages = sessionPkgs;
}
