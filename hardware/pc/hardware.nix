{
  config,
  lib,
  inputs,
  pkgs,
  modulesPath,
  ...
}: let
  powerMode = "performance";
  gpu-unlock-firmware = pkgs.callPackage ../../packages/gpu-unlock/firmware.nix {};
  gpu-unlock = config.boot.kernelPackages.callPackage ../../packages/gpu-unlock/module.nix {};
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
    extraModulePackages = [config.boot.kernelPackages.nvidia_x11 gpu-unlock];
    # gpu_unlock must run before nvidia binds the GPU. It is a no-op unless
    # gpu_unlock.targets is set (see kernelParams).
    # A "softdep nvidia pre:" line is not enough: nvidia's own embedded
    # softdep takes precedence, so hook the load with an install command.
    extraModprobeConfig = ''
      install nvidia ${pkgs.kmod}/bin/modprobe gpu_unlock; ${pkgs.kmod}/bin/modprobe --ignore-install nvidia $CMDLINE_OPTS
    '';
    kernelParams = [
      "boot.shell_on_fail"
      "net.ifnames=0"
      "biosdevname=0"
      "iomem=relaxed"
      "mitigations=off"
      "r8169.eee_enable=0"
      "r8169.use_dac=1"
      # Unlock full-rate FP16/BF16 tensor cores on the 3090
      # (https://github.com/Zagitta/gpu-unlock). Volatile; drop to revert.
      "gpu_unlock.targets=all"
    ];
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

    firmware = [gpu-unlock-firmware];
  };

  environment.systemPackages = with pkgs; [
    clinfo
    (llama-cpp.override { cudaSupport = true; })
  ];

  networking.interfaces.eth0.wakeOnLan.enable = true;
}
