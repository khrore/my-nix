{
  lib,
  pkgs-unstable,
  mylib,
  system,
  isDisplay,
  inputs,
  ...
}:
let
  darwinUtils = with pkgs-unstable; lib.optionals (mylib.isDarwin system) [ orbstack ];
  # Linux desktop utilities
  linuxDisplayUtils =
    with pkgs-unstable;
    lib.optionals (mylib.isLinux system && isDisplay) [
      # Wayland-specific tools
      cliphist
      grimblast
      wl-clipboard
      showmethekey
      wtype

      # Desktop tools
      brightnessctl
      playerctl
      libsForQt5.qt5ct
      libsForQt5.qtwayland
      libxkbcommon
      rofimoji
      nwg-look
      alsa-lib
    ];

  # Linux-specific utilities
  linuxUtils =
    with pkgs-unstable;
    lib.optionals (mylib.isLinux system) [
      nftables
      bubblewrap
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
    cloc

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
    # xpdf # insecure
    poppler-utils
    mupdf
    imagemagick
    qpdf
  ];
  flakeUtils = [
    inputs.agenix.packages.${system}.default
  ];
in
{
  home.packages = sharedUtils ++ linuxDisplayUtils ++ linuxUtils ++ darwinUtils ++ flakeUtils;
}
