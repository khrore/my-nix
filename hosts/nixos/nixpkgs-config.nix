{
  nixpkgs.config.cudaSupport = true;
  networking.firewall.allowedTCPPorts = [ 8188 ];
}
