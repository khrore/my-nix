{
  username,
  pkgs-unstable,
  shell,
  ...
}:
{
  users = {
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
}
