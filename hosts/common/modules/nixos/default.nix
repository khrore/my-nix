{ isDisplay, stateVersion, ... }:
{
  imports = [
    ./audio.nix
    ./boot.nix
    ./compat.nix
    ./fonts.nix
    ./location.nix
    ./nix-ld.nix
    ./programs.nix
    ./services.nix
    ./users.nix
    ./network.nix
  ]
  ++ (if isDisplay then [ ./hyprland.nix ] else [ ]);

  system.stateVersion = stateVersion;
}
