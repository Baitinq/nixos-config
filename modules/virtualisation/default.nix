{ config, pkgs, user, ... }:

{
  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    libvirtd.enable = true;
    virtualbox.host.enable = true;
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  users.users.${user}.extraGroups = [ "libvirtd" "docker" ];
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
}
