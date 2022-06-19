{ config, pkgs, user, ... }:

{
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  users.users.${user}.extraGroups = [ "docker" ];
}
