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
    {
      nixosConfigurations = import ./hosts {
        isNixOS = true;
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager;
      };

      homeConfigurations = import ./hosts {
        isNixOS = false;
        #no COde duplication here: TODO
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager;
      };
    };
}
