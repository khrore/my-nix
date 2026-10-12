{
  # Homebrew for macOS-native apps
  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "zap"; # Uninstall unlisted packages
      extraEnv = {
        HTTP_PROXY = "http://127.0.0.1:10808";
        HTTPS_PROXY = "http://127.0.0.1:10808";
        http_proxy = "http://127.0.0.1:10808";
        https_proxy = "http://127.0.0.1:10808";
      };
    };

    # GUI applications
    casks = [
      # Optional: macOS-native apps that aren't in nixpkgs
      # or are better installed via Homebrew
      # Examples:
      "localsend"
      "zen"
      "happ"
      "gimp"
      "docker-desktop"
      "codex"
      "claude-code"
      "zed"
      "ghostty"
      "chatgpt-atlas"
      "ungoogled-chromium"
      "nikitabobko/tap/aerospace"
    ];
  };
}
