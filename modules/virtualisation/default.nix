{ config, pkgs, user, ... }:

{
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    libvirtd.enable = true;
    virtualbox.host.enable = true;
  };

  users.users.${user}.extraGroups = [ "libvirtd" ];
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
}
