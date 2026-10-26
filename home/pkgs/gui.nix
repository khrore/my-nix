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

      # Other
      ghostty
      zed-editor
      obs-studio
      imv

      # Browser
      ungoogled-chromium
      qbittorrent
      vesktop
      telegram-desktop
    ];

  linuxFlakePkgs = lib.optionals (mylib.isLinux system && isDisplay) [
    inputs.codex-desktop-linux.packages."${system}".default
    inputs.zen-browser.packages.${pkgs-unstable.stdenv.hostPlatform.system}.default
  ];

  # Cross-platform GUI packages
  sharedPkgs =
    with pkgs-unstable;
    lib.optionals isDisplay [
      # Terminals
      kitty

      # Applications
      obsidian
      spotify
      mpv-unwrapped

      bitwarden-desktop

      # DB
      dbeaver-bin
      bruno
      plantuml
    ];
in
{
  home.packages = sharedPkgs ++ linuxPkgs ++ linuxFlakePkgs;
}
