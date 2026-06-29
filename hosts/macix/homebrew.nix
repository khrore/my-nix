{
  # Homebrew for macOS-native apps
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Uninstall unlisted packages
      upgrade = true;
      extraEnv = {
        HTTP_PROXY = "http://127.0.0.1:2080";
        HTTPS_PROXY = "http://127.0.0.1:2080";
        http_proxy = "http://127.0.0.1:2080";
        https_proxy = "http://127.0.0.1:2080";
      };
    };

    # CLI tools not available or better via Homebrew
    brews = [
      # Add any Mac-specific brews here if needed
      # "asmvik/formulae/yabai"
    ];

    # GUI applications
    casks = [
      # Optional: macOS-native apps that aren't in nixpkgs
      # or are better installed via Homebrew
      # Examples:
      "localsend"
      "zen@twilight"
      "docker-desktop"
      "codex"
      "claude-code"
      "zed"
      "ghostty"
      "anydesk"
      "chatgpt-atlas"
      "ungoogled-chromium"
      "qbittorrent"
      "nikitabobko/tap/aerospace"
    ];

    # Mac App Store apps (requires mas-cli)
    masApps = {
      # "Xcode" = 497799835;
    };
  };
}
