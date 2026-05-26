{
  lib,
  hostName,
  system,
  mylib,
  ...
}:
{
  networking = lib.mkIf (mylib.isLinux system) {
    inherit hostName;
  };
}
