{
  lib,
  pkgs-unstable,
  mylib,
  system,
  isCuda,
  ...
}:
let
  # CUDA-specific terminal tools
  nvidiaPackages =
    with pkgs-unstable;
    lib.optionals (mylib.isLinux system && isCuda) [
      btop-cuda
      gpustat
    ];

  noGpu =
    with pkgs-unstable;
    lib.optionals (!isCuda) [
      btop
    ];

  shared = with pkgs-unstable; [
    yazi
    neovim
    zellij
    lazygit
    lazydocker
    basalt

    # disk
    ncdu
    bitwarden-cli
  ];
in
{
  home.packages = shared ++ noGpu ++ nvidiaPackages;
}
