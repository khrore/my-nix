{
  lib,
  inputs,
  pkgs-unstable,
  mylib,
  system,
  isDisplay,
  ...
}:
let
  # Linux-specific GUI packages
  linuxPkgs =
    with pkgs-unstable;
    lib.optionals (mylib.isLinux system && isDisplay) [
      # Wayland/Hyprland tools (Linux only)
      waybar
      dunst
      rofi
      wlogout
      hyprlock
      hyprpaper
      hypridle
      hyprpicker
      hyprshot
      clipse
      nautilus

      # Other
      ghostty
      zed-editor
      obs-studio
      mpv
      anydesk

      # Browser
      ungoogled-chromium
      qbittorrent
      tor
      vesktop
    ];

  linuxFlakePkgs = lib.optionals (mylib.isLinux system && isDisplay) [
    inputs.zen-browser.packages."${system}".twilight
  ];

  # Cross-platform GUI packages
  sharedPkgs =
    with pkgs-unstable;
    lib.optionals isDisplay [
      # Terminals
      kitty

      # Applications
      obsidian
      telegram-desktop
      spotify

      # DB
      dbeaver-bin
      bruno
      plantuml
    ];
in
{
  home.packages = sharedPkgs ++ linuxPkgs ++ linuxFlakePkgs;
}
