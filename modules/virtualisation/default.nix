{ config, pkgs, user, ... }:

{
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.dnsname.enable = true;
    };
    libvirtd.enable = true;
    virtualbox.host.enable = true;
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    podman-compose
  ];

  users.users.${user}.extraGroups = [ "libvirtd" ];
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
}
