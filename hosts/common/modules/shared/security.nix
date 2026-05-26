{
  lib,
  repoRoot,
  username,
  system,
  mylib,
  ...
}:
let
  userHome = if mylib.isDarwin system then "/Users/${username}" else "/home/${username}";
in
{
  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [
    # Generate manually via `sudo ssh-keygen -A`
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  security.pki.certificateFiles = [
    (repoRoot + "/certs/dev-2.crt")
    (repoRoot + "/certs/dev-4.crt")
  ];

  age.secrets.atuin_key = {
    owner = username;
    path = "${userHome}/.local/share/atuin/shared_key";
  };

  services.openssh.enable = lib.mkDefault true;
}
