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
  }/.local/state/desktop/browser/chromium-policy.json";
  policyLink = pkgs.runCommandLocal "desktop-browser-theme-policy" { } ''
    ln -s ${lib.escapeShellArg policyFile} "$out"
  '';
in
{
  environment.sessionVariables.DESKTOP_CHROMIUM_POLICY = policyFile;
  environment.etc =
    lib.genAttrs
      [
        "chromium/policies/managed/desktop-theme.json"
        "opt/chrome/policies/managed/desktop-theme.json"
        "brave/policies/managed/desktop-theme.json"
        "opt/edge/policies/managed/desktop-theme.json"
      ]
      (_: {
        source = policyLink;
      });
}
