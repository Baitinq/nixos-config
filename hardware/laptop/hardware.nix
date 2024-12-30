{
  config,
  lib,
  inputs,
  pkgs,
  modulesPath,
  ...
}: let
  powerMode = "performance";
in {
  imports = [
    ./disks.nix
  ];

  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "usbhid" "sd_mod" "sdhci_pci"];
      kernelModules = [];
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm_intel"];
    extraModulePackages = [];
    kernelParams = ["net.ifnames=0" "biosdevname=0" "iomem=relaxed" "mitigations=off"];
  };

  powerManagement.cpuFreqGovernor = powerMode;

  services = {
    xserver = {
      videoDrivers = ["nvidia"];

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
    cpu.intel.updateMicrocode = true;

    graphics = {
      enable = true;
    };

    nvidia = {
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
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
