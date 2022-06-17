{ config, pkgs, ... }: {
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "gb";

  services.xserver.displayManager.startx.enable = true;
  services.xserver.windowManager.dwm.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  services.xserver.dpi = 96;

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    #wants = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart =
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
  systemd.user.services.polkit-gnome-authentication-agent-1.enable = true;

}
