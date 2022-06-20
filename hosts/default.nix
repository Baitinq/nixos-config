{ user, lib, nixpkgs, nur, inputs, home-manager, ... }:
let
  system = "x86_64-linux"; # System architecture

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true; # Allow proprietary software
    overlays = [
      nur.overlay
      (import ../packages)
      (import ../overlays)
    ];
  };

  inherit (nixpkgs.lib);

  secrets = import ../secrets;

  mkHost = hostname: lib.nixosSystem {
    inherit system;
    specialArgs = { inherit pkgs inputs user secrets hostname; };
    modules = [
      ./configuration.nix
      ./${hostname}
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit pkgs user secrets hostname inputs; };
        home-manager.users.${user} = {
          imports = [ ./home.nix ] ++ [ (import ./${ hostname }/home.nix) ];
        };
      }
    ];
  };
in
let hosts = [ "baitinq" "vm" ]; #TODO: generate from here. List to set + apply func
in
{
  baitinq = mkHost "baitinq";
  vm = mkHost "vm";
}
