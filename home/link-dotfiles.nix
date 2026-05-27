{
  config,
  pkgs,
  mylib,
  system,
  ...
}:

let
  platform =
    if mylib.isDarwin system then
      "darwin"
    else if mylib.isLinux system then
      "nixos"
    else
      "common";
  homeDir = config.home.homeDirectory;
  runtimeScript = pkgs.replaceVars ./link-dotfiles-runtime.sh {
    inherit platform homeDir;
  };

  linkScript = pkgs.writeShellScriptBin "link-dotfiles" ''
    set -e

    echo "Linking dotfiles for platform: ${platform}"
    ${pkgs.bash}/bin/bash ${runtimeScript}

    echo "Done! Dotfiles linked successfully."
  '';
in
{
  home.packages = [ linkScript ];

  home.activation.linkDotfiles = {
    after = [ "linkGeneration" ];
    before = [ ];
    data = ''
      ${pkgs.bash}/bin/bash ${runtimeScript}
    '';
  };
}
