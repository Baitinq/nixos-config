{ user, lib, nixpkgs, nur, inputs, home-manager, ... }:
let
  secrets = import ../secrets;
  
  hosts = [
    { hostname = "phobos"; system = "x86_64-linux"; location = secrets.main_location; }
    { hostname = "luna"; system = "x86_64-linux"; location = secrets.main_location; }
    { hostname = "vm"; system = "x86_64-linux"; location = secrets.main_location; }
  ];

  mkHost = hostname: system: location:
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
      extraArgs = { inherit pkgs inputs user secrets hostname location; };
    in
    nixpkgs.lib.nixosSystem {
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
    };
in
  /*
    We have a list of sets.
    Map each element of the list applying the mkHost function to its elements and returning a set in the listToAttrs format
    builtins.listToAttrs on the result
  */
builtins.listToAttrs (map ({ hostname, system, location }: { name = hostname; value = mkHost hostname system location; }) hosts)
