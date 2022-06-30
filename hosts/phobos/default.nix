# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, secrets, hostname, inputs, user, ... }: {

  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
  ];

  # Configure keymap in X11
  services.xserver.layout = "gb";

  # Pick only one of the below networking options.
  networking = {
    wireless = {
      enable = true; # Enables wireless support via wpa_supplicant.
      networks = secrets.wifi;
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

  environment.etc."nix-index/files".source = inputs.nix-index.legacyPackages.x86_64-linux.database;

}

