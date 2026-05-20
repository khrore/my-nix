{
  lib,
  stateVersion,
  hostName,
  username,
  system,
  mylib,
  pkgs-unstable,
  shell,
  ...
}:
let
  userHome = if mylib.isDarwin system then "/Users/${username}" else "/home/${username}";
in
{
  # You can import other NixOS modules here
  imports = [
    ./modules
    ./nixpkgs-config.nix
    ../../home
  ];

  networking = lib.mkIf (mylib.isLinux system) {
    inherit hostName;
  };

  users = lib.optionalAttrs (mylib.isLinux system) {
    defaultUserShell = pkgs-unstable.${shell};
    users.${username} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
      ];
    };
  };

  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [
    # Generate manually via `sudo ssh-keygen -A`
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  age.secrets.atuin_key = {
    owner = username;
    path = "${userHome}/.local/share/atuin/shared_key";
  };

  services.openssh.enable = lib.mkDefault true;

  system.stateVersion =
    if mylib.isDarwin system then
      5 # nix-darwin uses different versioning
    else
      stateVersion;
}
