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
    "${modulesPath}/profiles/all-hardware.nix"
  ];

  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "usb_storage" "sd_mod" "sdhci_acpi" "aesni_intel" "cryptd"];
      kernelModules = [];
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm_intel" "nvidia"];
    extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
    kernelParams = ["boot.shell_on_fail" "net.ifnames=0" "biosdevname=0" "iomem=relaxed" "mitigations=off"];
  };

  powerManagement.cpuFreqGovernor = powerMode;

  services = {
    xserver = {
      videoDrivers = ["nvidia"];
    };
    fstrim.enable = true;
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
  };

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  environment.systemPackages = with pkgs; [
    clinfo
  ];
}
