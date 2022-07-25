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

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
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
