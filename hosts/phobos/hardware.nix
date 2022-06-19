{ config, lib, pkgs, modulesPath, ... }:
let
  powerMode = "performance";
in
{
  imports = [ ];

  boot = {
    initrd = {
      availableKernelModules =
        [ "xhci_pci" "ahci" "usbhid" "sd_mod" "sdhci_pci" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm_intel" ];
    extraModulePackages = [ ];
    kernelParams = [ "net.ifnames=0" "biosdevname=0" "iomem=relaxed" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2a0ba6f5-a4ec-4614-9bd2-11b4a66d5d82";
    fsType = "ext4";
  };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = powerMode;

  #services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver = {
    videoDrivers = [ "intel" ];
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
    };

    # nvidia.modesetting.enable = true;
    /*nvidia.prime = {
      sync.enable = true;

      # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
      nvidiaBusId = "PCI:1:0:0";

      # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
      intelBusId = "PCI:0:2:0";
      };*/
  };

}
