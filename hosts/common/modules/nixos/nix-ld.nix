{
  lib,
  pkgs-unstable,
  isDisplay,
  ...
}:
{
  programs.nix-ld = {
    enable = true;
    libraries =
      with pkgs-unstable;
      [ neovim ]
      ++ lib.optionals isDisplay [
        zed-editor
      ];
  };
}
