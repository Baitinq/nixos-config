{ config, lib, inputs, pkgs, modulesPath, ... }:
{
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };

  boot.initrd.luks.devices."encrypted_boot" = {
    device = "/dev/disk/by-uuid/4f5ba100-5c69-49ce-b0cf-2f219a5e9e51";
    preLVM = true;
  };

  fileSystems."/boot" = {
    device = "/dev/mapper/encrypted_boot";
    fsType = "vfat";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/BD51-1431";
    fsType = "vfat";
  };

  boot.initrd.luks.devices."encrypted_nix".device = "/dev/disk/by-uuid/596e43d3-ccda-4f06-bce9-58d6a8c0dd79";

  fileSystems."/nix" = {
    device = "/dev/mapper/encrypted_nix";
    fsType = "btrfs";
    neededForBoot = true;
    options = [ "subvol=nix" "compress-force=zstd" "noatime" ];
  };

  boot.initrd.luks.devices."encrypted_home_and_persist".device = "/dev/disk/by-uuid/47a8ddde-1237-4a0f-84c4-f17fbd22ea3f";

  fileSystems."/persist" = {
    device = "/dev/mapper/encrypted_home_and_persist";
    fsType = "btrfs";
    neededForBoot = true;
    options = [ "subvol=persist" "compress-force=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/encrypted_home_and_persist";
    fsType = "btrfs";
    options = [ "subvol=home" "compress-force=zstd" ];
  };

  services.btrfs.autoScrub.enable = true;

  swapDevices = [ ];

  zramSwap.enable = true;

}