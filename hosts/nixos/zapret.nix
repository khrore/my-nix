{ config, ... }:
let
  cfg = config.services.zapret;
  fakePayloads = "${cfg.package}/share/zapret/files/fake";
  queueRule = "-m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num ${toString cfg.qnum} --queue-bypass";
  httpsRule = "-p tcp --dport 443 ${queueRule}";
  legacyHttpsRule = "-p tcp --dport 443 -m connbytes --connbytes 1:6 --connbytes-mode packets --connbytes-dir original ${queueRule}";
in
{
  assertions = [
    {
      assertion = !config.networking.nftables.enable;
      message = "Zapret HTTPS routing requires the iptables firewall.";
    }
  ];

  services.zapret = {
    enable = true;
    httpSupport = false;
    configureFirewall = false;

    # Keep hostlists on each profile: the module appends its whitelist only
    # to the final profile. Other domains pass through without modification.
    params = [
      "--filter-tcp=443"
      "--hostlist-domains=youtube.com,youtu.be,googlevideo.com,ytimg.com,ggpht.com,youtubei.googleapis.com"
      "--dpi-desync=fakeddisorder"
      "--dpi-desync-split-pos=midsld"
      "--dpi-desync-fooling=badseq"

      "--new"
      "--filter-tcp=443"
      "--hostlist-domains=discord.com,discord.gg,discordapp.com,discordapp.net,discord.media"
      # Flowseal general (ALT4), TCP profile at eb16c1419057e36b8a36fbe7c959483450e6ac8b.
      # Its STUN and Google TLS fake payloads match the files bundled with zapret.
      "--dpi-desync=fake,multisplit"
      "--dpi-desync-repeats=6"
      "--dpi-desync-fooling=badseq"
      "--dpi-desync-badseq-increment=1000"
      "--dpi-desync-fake-tls=${fakePayloads}/stun.bin"
      "--dpi-desync-fake-tls=${fakePayloads}/tls_clienthello_www_google_com.bin"
    ];
  };

  # Queue outgoing HTTPS packets throughout the connection, matching ALT4's
  # capture behavior. The profiles above select which domains to modify.
  networking.firewall = {
    extraCommands = ''
      for iptablesCmd in iptables ip6tables; do
        # Remove rules left by the upstream module when switching configurations.
        while $iptablesCmd -w -t mangle -C POSTROUTING ${legacyHttpsRule} 2>/dev/null; do
          $iptablesCmd -w -t mangle -D POSTROUTING ${legacyHttpsRule}
        done
        $iptablesCmd -w -t mangle -C POSTROUTING ${httpsRule} 2>/dev/null || \
          $iptablesCmd -w -t mangle -I POSTROUTING ${httpsRule}
      done
    '';
    extraStopCommands = ''
      for iptablesCmd in iptables ip6tables; do
        while $iptablesCmd -w -t mangle -C POSTROUTING ${httpsRule} 2>/dev/null; do
          $iptablesCmd -w -t mangle -D POSTROUTING ${httpsRule}
        done
      done
    '';
  };
}
