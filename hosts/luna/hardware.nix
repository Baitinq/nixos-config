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
    device = "/dev/disk/by-uuid/3187-3464";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/285219b7-4351-4a29-927e-7beabe7131f7";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/6d852aa1-81de-43f5-9c45-567a68b99b0b";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/2fbd48bf-9ee6-4e60-8d65-8a89fc696655";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
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
