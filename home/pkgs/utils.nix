{
  lib,
  pkgs-unstable,
  mylib,
  system,
  inputs,
  ...
}:
let
  darwinUtils = with pkgs-unstable; lib.optionals (mylib.isDarwin system) [ orbstack ];
  # Linux-specific utilities
  linuxUtils =
    with pkgs-unstable;
    lib.optionals (mylib.isLinux system) [
      # Wayland-specific
      cliphist
      grimblast
      wl-clipboard
      showmethekey
      wtype
      nftables

      # Linux-specific tools
      brightnessctl
      playerctl
      libsForQt5.qt5ct
      libsForQt5.qt5.qtwayland
      libxkbcommon
      rofimoji
      nwg-look
      alsa-lib
      catppuccin-cursors.mochaDark
    ];

  # Cross-platform utilities
  sharedUtils = with pkgs-unstable; [
    # Git
    git
    gh

    # Media tools
    ffmpeg

    # CLI utilities
    nh
    yt-dlp
    file
    libnotify
    jq
    carapace
    vivid

    # Networking
    sing-box
    wget
    mtr
    iperf3
    socat
    nmap
    ipcalc
    openssl
    prettyping

    # Encription
    gnupg

    # Archives
    zip
    unzip
    xz
    p7zip

    # Docs
    pandoc
    texliveSmall
  ];
  flakeUtils = [
    inputs.agenix.packages.${system}.default
  ];
in
{
  home.packages = sharedUtils ++ linuxUtils ++ darwinUtils ++ flakeUtils;
}
