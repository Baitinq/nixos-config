{ config, pkgs, user, ... }:

{
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    virtualbox = {
      host = {
        enable = true;
      };
      guest = {
        enable = true;
        x11 = true;
      };
    };
  };

  users.users.${user}.extraGroups = [ "docker" "libvirtd" ];
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
}
