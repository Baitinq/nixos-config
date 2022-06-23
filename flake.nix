{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, nur }:
    let user = "baitinq";
    in
    {
      nixosConfigurations = import ./hosts {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager nur user;
      };
    };
}
