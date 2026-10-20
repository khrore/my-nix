{ pkgs-unstable, ... }:
{
  fonts = {
    fontDir.enable = true;
    packages = [
      pkgs-unstable.inter
    ]
    ++ (with pkgs-unstable.nerd-fonts; [
      jetbrains-mono
      ubuntu
      liberation
    ]);
    fontconfig = {
      defaultFonts = {
        serif = [ "Liberation Serif" ];
        sansSerif = [
          "Inter"
          "Liberation Sans"
        ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };
}
