{ config, pkgs, ... }:
{
  # Starting graphical-session.target doesn't work coz systemd. NixOS has a bug
  # where the graphical-session.target isn't started on wayland (https://github.com/NixOS/nixpkgs/issues/169143).
  # We are kind of screwed :)
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "wayland-session" ''
        /run/current-system/systemd/bin/systemctl --user start graphical-session.target
        dbus-run-session "$@"
        /run/current-system/systemd/bin/systemctl --user stop graphical-session.target
      '')
  ];

  services.xserver = {
    enable = true;

    displayManager.startx.enable = true;

    dpi = 96;

    excludePackages = with pkgs; [
      xterm
    ];
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
