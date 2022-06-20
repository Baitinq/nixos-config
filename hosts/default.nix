{ user, lib, nixpkgs, nur, inputs, home-manager, ... }:
let
  mkHost = hostname: system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true; # Allow proprietary software
        overlays = [
          nur.overlay
          (import ../packages)
          (import ../overlays)
        ];
      };
      secrets = import ../secrets;
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit pkgs inputs user secrets hostname;
      };
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
  baitinq = mkHost "baitinq" "x86_64-linux";
  vm = mkHost "vm" "x86_64-linux";
}
