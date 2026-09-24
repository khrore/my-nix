{
  pkgs,
  shell,
  hostName,
  username,
  ...
}:
{
  # Import common configuration
  imports = [
    ../common/default.nix
    ./homebrew.nix
    ./streaming.nix
  ];

  # Hostname
  networking = {
    inherit hostName;
    computerName = hostName;
    localHostName = hostName;
  };

  system = {
    # Set primary user (required for homebrew and system defaults)
    primaryUser = username;

    # System defaults (macOS-specific settings)
    defaults = {
      dock = {
        autohide = true;
        orientation = "bottom";
        show-recents = false;
        tilesize = 48;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
    };
  };

  # Enable Touch ID for sudo (updated option name)
  security.pam.services.sudo_local.touchIdAuth = true;

  # User configuration
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.${shell};
  };

  # Allow SSH access to macix via public key auth.
  services.openssh = {
    extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      PermitRootLogin no
      PubkeyAuthentication yes
    '';
  };

  # Enable shells
  programs = {
    fish.enable = true;
    zsh.enable = true;
    bash.enable = true;
  };
}
