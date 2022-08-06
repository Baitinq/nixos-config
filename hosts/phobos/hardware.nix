{ config, lib, pkgs, modulesPath, ... }:
let
  powerMode = "performance";
in
{
  imports = [ ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" "sdhci_pci" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm_intel" ];
    extraModulePackages = [ ];
    kernelParams = [ "net.ifnames=0" "biosdevname=0" "iomem=relaxed" "mitigations=off" ];
  };

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

  powerManagement.cpuFreqGovernor = powerMode;

  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];

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
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
    };

    nvidia = {
      prime = {
        sync.enable = true;

        # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
        nvidiaBusId = "PCI:1:0:0";

        # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
        intelBusId = "PCI:0:2:0";
      };
    };
  };

}
