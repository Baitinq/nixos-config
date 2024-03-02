{
  description = "My Nix(\"OS\" or \"\") configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:NixOS/nixos-hardware";

    impermanence.url = "github:nix-community/impermanence";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    nixtest.url = "github:jetpack-io/nixtest";

    nix-index.url = "github:Mic92/nix-index-database";

    emacs-overlay.url = "github:nix-community/emacs-overlay";

    hosts = {
      url = "github:StevenBlack/hosts";
      flake = false;
    };

    arkenfox-userjs = {
      url = "github:arkenfox/user.js";
      flake = false;
    };

    wallpapers = {
      url = "github:Baitinq/Wallpapers";
      flake = false;
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, nix-darwin, ... }:
    let
      user = "baitinq";

      secrets = import ./secrets;

      dotfiles = ./dotfiles;

      hosts = [
        { host = "phobos"; extraOverlays = [ ]; extraModules = [ ]; timezone = secrets.main_timezone; location = secrets.main_location; }
        { host = "luna"; extraOverlays = [ ]; extraModules = [ ]; timezone = secrets.main_timezone; location = secrets.main_location; }
      ];

      hardwares = [
        { hardware = "pc"; stateVersion = "22.05"; }
        { hardware = "laptop"; stateVersion = "22.05"; }
        { hardware = "chromebook"; stateVersion = "22.05"; }
        { hardware = "thinkpad"; stateVersion = "22.05"; }
        { hardware = "virtualbox"; stateVersion = "22.05"; }
      ];

      systems = [
        { system = "x86_64-linux"; }
        { system = "x86_64-darwin"; }
        { system = "aarch64-linux"; }
        { system = "aarch64-darwin"; }
      ];


      commonInherits = {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager nix-darwin;
        inherit user secrets dotfiles hosts hardwares systems;
      };
    in
    {
      nixosConfigurations = import ./hosts (commonInherits // {
        isNixOS = true;
        isMacOS = false;
        isIso = false;
        isHardware = true;
      });

      darwinConfigurations = import ./hosts (commonInherits // {
        isNixOS = false;
        isMacOS = true;
        isIso = false;
        isHardware = true;
        user = "${secrets.darwin_user}";
      });

      homeConfigurations = import ./hosts (commonInherits // {
        isNixOS = false;
        isMacOS = false;
        isIso = false;
        isHardware = false;
      });

      isoConfigurations = import ./hosts (commonInherits // {
        isNixOS = true;
        isMacOS = false;
        isIso = true;
        isHardware = false;
        user = "nixos";
      });

      nixosNoHardwareConfigurations = import ./hosts (commonInherits // {
        isNixOS = true;
        isMacOS = false;
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


      tests = inputs.nixtest.run ./.;
    };
}
