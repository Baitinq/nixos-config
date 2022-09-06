{ config, lib, inputs, pkgs, modulesPath, isIso, ... }:
{
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0A8B-3968";
    fsType = "vfat";
  };

  boot.initrd.luks.devices."encrypted_root".device = "/dev/disk/by-uuid/095dc267-9281-4535-9491-b3fcded614a8";

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

  services.btrfs.autoScrub.enable = if !isIso then true else false;

  zramSwap.enable = true;

}
