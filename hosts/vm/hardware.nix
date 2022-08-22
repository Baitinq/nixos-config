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
    kernelModules = [ ];
    extraModulePackages = [ ];
    kernelParams = [ "net.ifnames=0" "biosdevname=0" "mitigations=off" ];
  };

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
