{ config, lib, inputs, pkgs, modulesPath, ... }:
{
  imports = [
    ./disks.nix
  ];

  boot = {
    initrd = {
      availableKernelModules =
        [ "ata_piix" "ohci_pci" "sd_mod" "sr_mod" ];
      kernelModules = [ ];
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ ];
    extraModulePackages = [ ];
    kernelParams = [ "net.ifnames=0" "biosdevname=0" "mitigations=off" ];
  };

  services.xserver = {
    # Enable touchpad support (enabled default in most desktopManager).
    synaptics.enable = false;
  };

  hardware = {
    graphics = {
      enable = true;
    };
  };

  environment.sessionVariables = {
    "WLR_NO_HARDWARE_CURSORS" = "1";
  };

  virtualisation.virtualbox.guest.enable = true;

}
