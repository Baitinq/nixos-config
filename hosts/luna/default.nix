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
    # don’t shutdown when power button is short-pressed
    logind.settings.Login.HandlePowerKey = "ignore";
  };

  environment.systemPackages = with pkgs; [
  ];
}
