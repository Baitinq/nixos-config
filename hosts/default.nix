{ lib, inputs, isNixOS, nixpkgs, home-manager, ... }:
let
  user = "baitinq";

  secrets = import ../secrets;

  hosts = [
    { hostname = "phobos"; system = "x86_64-linux"; timezone = secrets.main_timezone; location = secrets.main_location; }
    { hostname = "luna"; system = "x86_64-linux"; timezone = secrets.main_timezone; location = secrets.main_location; }
    { hostname = "vm"; system = "x86_64-linux"; timezone = secrets.main_timezone; location = secrets.main_location; }
  ];

  mkHost = { hostname, system, timezone, location }: isNixOS:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true; # Allow proprietary software
        overlays = [
          inputs.nur.overlay
          (import ../packages)
          (import ../overlays)
        ];
      };
      extraArgs = { inherit pkgs inputs user secrets hostname timezone location; };
    in
    if isNixOS
    then
      nixpkgs.lib.nixosSystem
        {
          inherit system;
          specialArgs = extraArgs;
          modules = [
            ./configuration.nix
            ./${hostname}
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = extraArgs;
              home-manager.users.${user} = {
                imports = [ ./home.nix ] ++ [ (import ./${ hostname }/home.nix) ];
              };
            }
          ];
        }
    else
      home-manager.lib.homeManagerConfiguration
        {
          inherit pkgs;
          extraSpecialArgs = extraArgs;
          modules = [ ./home.nix ] ++ [ (import ./${ hostname }/home.nix) ];
        };
in
  /*
    We have a list of sets.
    Map each element of the list applying the mkHost function to its elements and returning a set in the listToAttrs format
    builtins.listToAttrs on the result
  */
builtins.listToAttrs (map ({ hostname, system, timezone, location }: { name = hostname; value = mkHost { inherit hostname system timezone location; } isNixOS; }) hosts)
