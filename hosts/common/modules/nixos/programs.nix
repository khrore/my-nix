{ pkgs-unstable, ... }:
let
  throneNixosPatch = pkgs-unstable.writeText "throne-nixos-1.2.4.patch" ''
    diff --git a/src/global/Configs.cpp b/src/global/Configs.cpp
    --- a/src/global/Configs.cpp
    +++ b/src/global/Configs.cpp
    @@ -45,6 +45,12 @@ namespace Configs {
         }

         QString FindCoreRealPath() {
    +        // Find the NixOS security wrapper before the immutable store binary.
    +        QString path_for_nixos = QStandardPaths::findExecutable("ThroneCore");
    +        if (!path_for_nixos.isEmpty()) {
    +            return path_for_nixos;
    +        }
    +
             auto fn = QApplication::applicationDirPath() + "/ThroneCore";
     #ifdef Q_OS_WIN
             fn += ".exe";
    diff --git a/src/ui/mainWindow/mainwindow_system.cpp b/src/ui/mainWindow/mainwindow_system.cpp
    --- a/src/ui/mainWindow/mainwindow_system.cpp
    +++ b/src/ui/mainWindow/mainwindow_system.cpp
    @@ -193,6 +193,16 @@ bool MainWindow::get_elevated_permissions(ExitReason reason) {
             return true;
         }
         if (Configs::IsAdmin()) return true;
    +#ifdef Q_OS_LINUX
    +    QMessageBox::critical(
    +        GetMessageBoxParent(),
    +        tr("Unable to elevate privileges when installed with Nix"),
    +        tr("Due to the read-only property of the Nix store, Throne cannot set suid on ThroneCore. Enable programs.throne.tunMode in the NixOS configuration instead."),
    +        QMessageBox::Ok
    +    );
    +    return false;
    +#endif
    +
     #ifdef Q_OS_LINUX
         if (!Linux_HavePkexec()) {
             MessageBoxWarning(software_name, "Please install \"pkexec\" first.");
  '';
  throne = pkgs-unstable.throne.overrideAttrs (
    finalAttrs: previousAttrs: {
      version = "1.2.4";
      src = pkgs-unstable.fetchFromGitHub {
        owner = "throneproj";
        repo = "Throne";
        tag = finalAttrs.version;
        hash = "sha256-fDaU3xjrpjeW8MePBaj5aNGJ2GrNQ3/M3LhtBoU+I/A=";
      };
      patches =
        builtins.filter (
          patch: !(pkgs-unstable.lib.hasSuffix "nixos-disable-setuid-request.patch" (toString patch))
        ) previousAttrs.patches
        ++ [ throneNixosPatch ];
      passthru = previousAttrs.passthru // {
        core = previousAttrs.passthru.core.overrideAttrs {
          inherit (finalAttrs) version src;
          vendorHash = "sha256-qr45kA/xw3NARNUAj5OMjNE1JUeYQXkEXArsyc9K5jA=";
        };
      };
    }
  );
in
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
      package = throne;
      tunMode.enable = true;
    };
  };
}
