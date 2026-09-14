{
  mylib,
  username,
  pkgs-unstable,
  system,
  inputs,
  stateVersion,
  isCuda,
  isDisplay,
  ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      inherit
        pkgs-unstable
        inputs
        username
        mylib
        system
        isCuda
        isDisplay
        ;
    };

    users.${username} = {
      home = {
        inherit stateVersion;
        inherit username;
        homeDirectory = if mylib.isDarwin system then "/Users/${username}" else "/home/${username}";
      };

      imports = mylib.scanPaths ./pkgs ++ [
        ./omarchy.nix
        ./link-dotfiles.nix
      ];

      programs.home-manager.enable = true;
    };
  };
}
