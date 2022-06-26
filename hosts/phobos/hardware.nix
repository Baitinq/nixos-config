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
    kernelParams = [ "net.ifnames=0" "biosdevname=0" "iomem=relaxed" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0A8B-3968";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/9a450653-8369-4850-af4f-cbec7cac8a99";
    fsType = "btrfs";
    options = [ "subvol=root" "compress-force=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/9a450653-8369-4850-af4f-cbec7cac8a99";
    fsType = "btrfs";
    options = [ "subvol=home" "compress-force=zstd" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/9a450653-8369-4850-af4f-cbec7cac8a99";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress-force=zstd" "noatime" ];
  };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = powerMode;

  services.xserver = {
    videoDrivers = [ "nvidia" ];

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
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
