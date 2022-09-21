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
        { host = "phobos"; system = "x86_64-linux"; extraOverlays = [ ]; extraModules = [ ]; timezone = secrets.main_timezone; location = secrets.main_location; }
        { host = "luna"; system = "x86_64-linux"; extraOverlays = [ ]; extraModules = [ ]; timezone = secrets.main_timezone; location = secrets.main_location; }
      ];

      hardwares = [
        { hardware = "laptop"; }
        { hardware = "chromebook"; }
        { hardware = "virtualbox"; }
      ];


      commonInherits = {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager;
        inherit user secrets dotfiles hosts hardwares;
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
    };
}
