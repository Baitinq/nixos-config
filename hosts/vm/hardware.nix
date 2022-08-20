{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ ];

  boot = {
    initrd = {
      availableKernelModules =
        [ "ata_piix" "ohci_pci" "sd_mod" "sr_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ ];
    extraModulePackages = [ ];
    kernelParams = [ "net.ifnames=0" "biosdevname=0" "mitigations=off" ];
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

  services.xserver = {
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
    };
  };

  virtualisation.virtualbox.guest.enable = true;

}
