{
  inputs,
  lib,
  mylib,
  pkgs,
  pkgs-unstable,
  system,
  ...
}:
{
  home.packages = [
    pkgs-unstable.opencode
  ]
  ++ lib.optionals (mylib.isLinux system) [
    (inputs.delta.packages.${system}.delta.overrideAttrs (old: {
      # Delta's bundled libxcb needs these libraries in its search path.
      installPhase =
        let
          xcbDependencies = lib.makeLibraryPath [
            pkgs.libxau
            pkgs.libxdmcp
          ];
        in
        lib.replaceStrings [ "$appDir/lib:" ] [ "$appDir/lib:${xcbDependencies}:" ] old.installPhase;
    }))
  ];
}
