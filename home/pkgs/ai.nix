{
  pkgs-unstable,
  ...
}:
{
  home.packages = with pkgs-unstable; [
    qwen-code
    opencode
  ];
}
