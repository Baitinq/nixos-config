{ config, lib, pkgs, modulesPath, ... }:
let
  powerMode = "schedutil";
in
{
  imports = [ ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "usb_storage" "sd_mod" "sdhci_acpi" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm_intel" ];
    extraModulePackages = [ ];
    kernelParams = [ "net.ifnames=0" "biosdevname=0" "iomem=relaxed" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/71B3-0F04";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/af0f88f6-d4db-471e-b5b7-2c0a1c314c23";
    fsType = "btrfs";
    options = [ "subvol=root" "compress-force=zstd" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/af0f88f6-d4db-471e-b5b7-2c0a1c314c23";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress-force=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/d7d4ebea-7c4b-4b1b-afdf-8b39f686276e";
    fsType = "btrfs";
    options = [ "subvol=home" "compress-force=zstd" ];
  };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = powerMode;

  services = {
    xserver = {
      videoDrivers = [ "intel" ];

      # Enable touchpad support (enabled default in most desktopManager).
      synaptics = {
        enable = true;
        palmDetect = true;
        twoFingerScroll = true;
        minSpeed = "1.0";
        maxSpeed = "1.12";
        accelFactor = "0.01";
      };
    };
    fstrim.enable = true;
    tlp.enable = true;
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

}
