{ pkgs, username, ... }:
let
  settings = (import ../common/mediamtx-settings.nix) // {
    # Unlike NixOS, macOS does not have a port allowlist in this configuration.
    rtsp = false;
    webrtc = false;
    srt = false;
    moq = false;
  };
  configFile = (pkgs.formats.yaml_1_2 { }).generate "mediamtx.yaml" settings;
in
{
  launchd.daemons.mediamtx.serviceConfig = {
    ProgramArguments = [
      "${pkgs.mediamtx}/bin/mediamtx"
      "${configFile}"
    ];
    UserName = username;
    RunAtLoad = true;
    KeepAlive = true;
  };
}
