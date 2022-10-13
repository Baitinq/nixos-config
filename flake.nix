{
  description = "My Nix(\"OS\" or \"\") configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:NixOS/nixos-hardware";

    impermanence.url = "github:nix-community/impermanence";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    nix-index.url = "github:Mic92/nix-index-database";

    wallpapers = {
      url = "github:Baitinq/Wallpapers";
      flake = false;
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
    let
      user = "baitinq";

      secrets = import ./secrets;

      dotfiles = ./dotfiles;

      hosts = [
        { host = "phobos"; extraOverlays = [ ]; extraModules = [ ]; timezone = secrets.main_timezone; location = secrets.main_location; }
        { host = "luna"; extraOverlays = [ ]; extraModules = [ ]; timezone = secrets.main_timezone; location = secrets.main_location; }
      ];

      hardwares = [
        { hardware = "laptop"; }
        { hardware = "chromebook"; }
        { hardware = "virtualbox"; }
      ];

      systems = [
        { system = "x86_64-linux"; }
        { system = "x86_64-darwin"; }
        { system = "aarch64-linux"; }
        { system = "aarch64-darwin"; }
      ];


      commonInherits = {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager;
        inherit user secrets dotfiles hosts hardwares systems;
      };
    in
    {
      nixosConfigurations = import ./hosts (commonInherits // {
        isNixOS = true;
        isIso = false;
        isHardware = true;
      });

      homeConfigurations = import ./hosts (commonInherits // {
        isNixOS = false;
        isIso = false;
        isHardware = false;
      });

      isoConfigurations = import ./hosts (commonInherits // {
        isNixOS = true;
        isIso = true;
        isHardware = false;
        user = "nixos";
      });

      nixosNoHardwareConfigurations = import ./hosts (commonInherits // {
        isNixOS = true;
        isIso = false;
        isHardware = false;
      });


      deploy = {
        magicRollback = true;
        autoRollback = true;

        nodes = builtins.mapAttrs
          (_: nixosConfig: {
            hostname = "${nixosConfig.config.networking.hostName}";

            profiles.system = {
              user = "root";
              path = inputs.deploy-rs.lib.${nixosConfig.config.nixpkgs.system}.activate.nixos nixosConfig;
            };
          })
          self.nixosConfigurations;
      };

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
    };
}
