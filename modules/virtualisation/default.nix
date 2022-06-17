{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  users.users.baitinq.extraGroups = [ "docker" ];

  virtualisation.libvirtd.enable = true;
}
