{
  # OBS publishes locally; only HLS playback is exposed to the LAN.
  rtmpAddress = "127.0.0.1:1935";
  hlsAddress = ":8888";
  paths.obs.source = "publisher";
}
