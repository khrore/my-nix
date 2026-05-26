{ username, nixpkgsConfig, ... }:
{
  nixpkgs.config = nixpkgsConfig;
  nix.settings = {
    # Enables flakes
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "${username}" ];
  };
}
