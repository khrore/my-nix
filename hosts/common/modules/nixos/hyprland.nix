{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
}
