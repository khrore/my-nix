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

  linuxPackages =
    with pkgs-unstable;
    lib.optionals (mylib.isLinux system) [
      imv

      # Moved to brew
      zed-editor
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
  ];
in
{
  home.packages = shared ++ linuxPackages ++ noGpu ++ nvidiaPackages;
}
