{ config, lib, inputs, pkgs, modulesPath, ... }:
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
  };

  boot.initrd.luks.devices."encrypted_boot".device = "/dev/disk/by-partlabel/boot";

  fileSystems."/boot" = {
    device = "/dev/mapper/encrypted_boot";
    fsType = "vfat";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-partlabel/efi";
    fsType = "vfat";
  };

  boot.initrd.luks.devices."encrypted_root".device = "/dev/disk/by-partlabel/root";

  fileSystems."/nix" = {
    device = "/dev/mapper/encrypted_root";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress-force=zstd" "noatime" ];
  };

  fileSystems."/persist" = {
    device = "/dev/mapper/encrypted_root";
    fsType = "btrfs";
    neededForBoot = true;
    options = [ "subvol=persist" "compress-force=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/encrypted_root";
    fsType = "btrfs";
    options = [ "subvol=home" "compress-force=zstd" ];
  };

  swapDevices = [ ];

  zramSwap.enable = true;

}
