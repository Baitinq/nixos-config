{ config, pkgs, ... }:

{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
  };

  # Recent fix for pipewire-pulse breakage
  systemd.user.services.pipewire-pulse.path = [ pkgs.pulseaudio ];

  sound.enable = false;
}

