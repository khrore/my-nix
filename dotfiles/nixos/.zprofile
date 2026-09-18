# Start the graphical session automatically after logging in on the primary TTY.
if [[ "${XDG_VTNR:-}" == 1 && -z "${WAYLAND_DISPLAY:-}" ]] && uwsm check may-start; then
  exec uwsm start -e -D Hyprland hyprland.desktop
fi
