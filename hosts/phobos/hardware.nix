{ config, lib, pkgs, modulesPath, ... }:
let
  powerMode = "performance";
in
{
  imports = [ ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "usbhid" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm_intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "net.ifnames=0" "biosdevname=0" "iomem=relaxed" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2a0ba6f5-a4ec-4614-9bd2-11b4a66d5d82";
    fsType = "ext4";
  };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = powerMode;

  services.xserver.videoDrivers = [ "intel" ];
  #  hardware.nvidia.modesetting.enable = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  #services.xserver.videoDrivers = [ "nvidia" ];

  /* hardware.nvidia.prime = {
    sync.enable = true;

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";
    };
  */
}
