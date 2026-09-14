{
  isDisplay,
  lib,
  mylib,
  nixpkgsConfig,
  system,
  username,
  ...
}:
{
  nixpkgs.config = nixpkgsConfig;
  nix.settings = {
    # Enables flakes
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "${username}" ];
  }
  // lib.optionalAttrs (mylib.isLinux system && isDisplay) {
    extra-substituters = [ "https://codex-desktop-linux.cachix.org" ];
    extra-trusted-public-keys = [
      "codex-desktop-linux.cachix.org-1:nX/xy6AdK9hQE24A8ALGjkCKj2ObFmcnemiL5Cid4nk="
    ];
  };
}
