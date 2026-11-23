{
  config,
  lib,
  repoRoot,
  username,
  system,
  mylib,
  ...
}:
let
  isDarwin = mylib.isDarwin system;
  userHome = if isDarwin then "/Users/${username}" else "/home/${username}";
  atuinDataDir = "${userHome}/.local/share/atuin";
in
{
  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [
    # Generate manually via `sudo ssh-keygen -A`
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  age.secrets.atuin_key = {
    owner = username;
    path = "${atuinDataDir}/shared_key";
  };

  services.openssh.enable = lib.mkDefault true;
}
// lib.optionalAttrs (!isDarwin) {
  # Agenix can create this directory as root, but Atuin needs it writable.
  systemd.tmpfiles.rules = [
    "d ${atuinDataDir} 0700 ${username} ${config.users.users.${username}.group} - -"
  ];
}
