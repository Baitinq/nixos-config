{ config, pkgs, lib, secrets, hostname, inputs, user, ... }: {

  imports = [
  ];

  # Configure keymap in X11
  services.xserver.layout = "gb";

  # Pick only one of the below networking options.
  networking = {
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  environment.systemPackages = with pkgs;
    [

    ];

  environment.etc."nix-index/files".source = inputs.nix-index.legacyPackages.x86_64-linux.database;

}

