{ pkgs, ... }:
{
  imports = [ ./hardware.nix ];

  environment.systemPackages = with pkgs; [
    flashrom
    nvramtool
  ];
}
