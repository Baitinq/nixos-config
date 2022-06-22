{ config, pkgs, ... }:
{
  services.xserver = {
    enable = true;

    displayManager.startx.enable = true;
    windowManager.dwm.enable = true;

    dpi = 96;
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wants = [ "graphical-session.target" ];
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
