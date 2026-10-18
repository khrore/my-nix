{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  # Browser policies are read from system paths, while the selected theme is
  # user state. This desktop host uses the primary user's palette system-wide.
  policyFile = "${
    config.users.users.${username}.home
  }/.local/state/linux-desktop/browser/chromium-policy.json";
  policyLink = pkgs.runCommandLocal "linux-desktop-browser-theme-policy" { } ''
    ln -s ${lib.escapeShellArg policyFile} "$out"
  '';
in
{
  environment.sessionVariables.LINUX_DESKTOP_CHROMIUM_POLICY = policyFile;
  environment.etc =
    lib.genAttrs
      [
        "chromium/policies/managed/linux-desktop-theme.json"
        "opt/chrome/policies/managed/linux-desktop-theme.json"
        "brave/policies/managed/linux-desktop-theme.json"
        "opt/edge/policies/managed/linux-desktop-theme.json"
      ]
      (_: {
        source = policyLink;
      });
}
