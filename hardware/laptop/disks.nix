{ config, lib, inputs, pkgs, modulesPath, isIso, ... }:
{

  environment.persistence."/persist" = {
    directories = [
      "/var/log"
      "/var/lib"
    ];
    files = [
      "/etc/machine-id"
      "/etc/nix/id_rsa"
    ];
  };

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "mode=755" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0A8B-3968";
    fsType = "vfat";
  };

  boot.initrd.luks.devices."encrypted_root".device = "/dev/disk/by-uuid/6db0e43d-f73f-4cf0-81f6-9391f9d03ca0";

  fileSystems."/persist" = {
    device = "/dev/mapper/encrypted_root";
    fsType = "btrfs";
    neededForBoot = true;
    options = [ "subvol=persist" "compress-force=zstd" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/encrypted_root";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress-force=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/encrypted_root";
    fsType = "btrfs";
    options = [ "subvol=home" "compress-force=zstd" ];
  };

  swapDevices = [ ];

  services.btrfs.autoScrub.enable = true;

  zramSwap.enable = true;

}
