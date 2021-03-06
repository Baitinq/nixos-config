{ config, pkgs, lib, secrets, hostname, inputs, user, ... }: {

  imports = [
    "${inputs.impermanence}/nixos.nix"

    ./hardware.nix

    ../../modules/power-save
    ../../modules/bluetooth
  ];

  services = {
    # Configure keymap in X11
    xserver.layout = "gb";
    logind.extraConfig = ''
      # don’t shutdown when power button is short-pressed
      HandlePowerKey=ignore
    '';
  };

  # Pick only one of the below networking options.
  networking = {
    wireless = {
      enable = true; # Enables wireless support via wpa_supplicant.
      networks = secrets.wifi_networks;
    };
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  environment.systemPackages = with pkgs; [
    dmidecode #needed for updating coreboot bios
    xf86_input_cmt #chromebook touchpad drivers
  ];

  environment.persistence."/persist" = {
    directories = [
      "/var/log"
      "/var/lib"
    ];
    files = [
      "/etc/machine-id"
      "/etc/nix/id_rsa"
    ];
  };

  environment.etc."nix-index/files".source = inputs.nix-index.legacyPackages.x86_64-linux.database;

}

