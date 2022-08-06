{ config, pkgs, lib, secrets, hostname, inputs, user, ... }: {

  imports = [
    "${inputs.impermanence}/nixos.nix"

    ./hardware.nix

    ../../modules/bluetooth
  ];

  # Configure keymap in X11
  services.xserver.layout = "gb";

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

  environment.systemPackages = with pkgs;
    [
    ];

  programs = {
    steam.enable = true;
  };

  /*  services.udev.extraRules = ''
    SUBSYSTEM=="input", ACTION=="add", ATTRS{bInterfaceProtocol}=="02", ATTRS{bInterfaceClass}=="03", ATTRS{bInterfaceSubClass}=="01", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/${user}/.Xauthority", RUN+="${pkgs.xorg.xf86inputsynaptics}/bin/synclient TouchpadOff=1"
    SUBSYSTEM=="input", ACTION=="remove", ATTRS{bInterfaceProtocol}=="02", ATTRS{bInterfaceClass}=="03", ATTRS{bInterfaceSubClass}=="01", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/${user}/.Xauthority", RUN+="${pkgs.xorg.xf86inputsynaptics}/bin/synclient TouchpadOff=0"
    '';
  */

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

