{
  services.mediamtx = {
    enable = true;
    settings = import ../common/mediamtx-settings.nix;
  };

  networking.firewall.allowedTCPPorts = [ 8888 ];
}
