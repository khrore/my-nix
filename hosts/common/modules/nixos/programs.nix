{
  pkgs,
  pkgs-unstable,
  isDisplay,
  ...
}:
{
  programs = {
    zsh.enable = true;
    fish = {
      enable = true;
      package = pkgs-unstable.fish;
    };
    localsend = {
      enable = true;
      package = pkgs-unstable.localsend;
      openFirewall = true;
    };
    throne = {
      enable = true;
      tunMode.enable = true;
      package =
        if isDisplay then
          pkgs.symlinkJoin {
            name = "throne-desktop-theme";
            paths = [ pkgs.throne ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram "$out/bin/Throne" \
                --set QT_QPA_PLATFORMTHEME qt6ct \
                --unset QT_STYLE_OVERRIDE \
                --prefix QT_PLUGIN_PATH : "${pkgs.qt6Packages.qt6ct}/lib/qt-6/plugins"
            '';
          }
        else
          pkgs.throne;
    };
  };
}
