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

    dotfiles = {
      url = "path:./dotfiles";
      flake = false;
    };

    wallpapers = {
      url = "github:Baitinq/Wallpapers";
      flake = false;
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
    let
      user = "baitinq";
      commonInherits = {
        inherit (nixpkgs) lib;
        inherit inputs user nixpkgs home-manager;
        extraModules = [ ];
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
