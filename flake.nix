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
    in
    {
      nixosConfigurations = import ./hosts {
        isNixOS = true;
        extraModules = [ ];
        isIso = false;
        inherit (nixpkgs) lib;
        inherit inputs user nixpkgs home-manager;
      };

      homeConfigurations = import ./hosts {
        isNixOS = false;
        extraModules = [ ];
        isIso = false;
        #no COde duplication here: TODO
        inherit (nixpkgs) lib;
        inherit inputs user nixpkgs home-manager;
      };

      isoConfigurations = import ./hosts {
        isNixOS = true;
        extraModules = [ ];
        isIso = true;
        user = "nixos";
        #no COde duplication here: TODO
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager;
      };
    };
}
