{
  config,
  pkgs,
  lib,
  secrets,
  hostname,
  inputs,
  user,
  ...
}: {
  imports = [];

  services = {
    # Configure keymap in X11
    xserver.xkb.layout = "us";
    logind.extraConfig = ''
      # don’t shutdown when power button is short-pressed
      HandlePowerKey=ignore
    '';
  };

  environment.systemPackages = with pkgs; [
  ];
}
