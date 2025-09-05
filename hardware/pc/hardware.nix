{
  config,
  lib,
  inputs,
  pkgs,
  modulesPath,
  ...
}: let
  powerMode = "performance";
  white-rgb = pkgs.writeScriptBin "white-rgb" ''
    #!/bin/sh
    ${pkgs.openrgb}/bin/openrgb --mode static --color FFFFFF
  '';
in {
  imports = [
    ./disks.nix
    "${modulesPath}/profiles/all-hardware.nix"
  ];

  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "usb_storage" "sd_mod" "sdhci_acpi" "aesni_intel" "cryptd"];
      kernelModules = [];
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm_intel" "nvidia" "i2c-dev"];
    extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
    kernelParams = ["boot.shell_on_fail" "net.ifnames=0" "biosdevname=0" "iomem=relaxed" "mitigations=off"];
  };

  powerManagement.cpuFreqGovernor = powerMode;

  services = {
    xserver = {
      videoDrivers = ["nvidia"];
    };
    fstrim.enable = true;
    hardware.openrgb.enable = true;
  };

  systemd.services.white-rgb = {
    description = "white-rgb";
    serviceConfig = {
      ExecStart = "${white-rgb}/bin/white-rgb";
      Type = "oneshot";
    };
    wantedBy = [ "multi-user.target" ];
  };

  hardware = {
    cpu.intel.updateMicrocode = true;

    graphics = {
      enable = true;
    };
    nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    nvidia-container-toolkit.enable = true;

    i2c.enable = true;
  };

  environment.systemPackages = with pkgs; [
    clinfo
  ];

  networking.interfaces.eth0.wakeOnLan.enable = true;
}
