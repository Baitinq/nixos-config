{ lib, inputs, extraModules, isNixOS, isIso, isHardware, user, nixpkgs, home-manager, ... }:
let
  secrets = import ../secrets;

  #TODO: Better implementation of hardare (not having to declare here but just in command)
  hosts = [
    { host = "phobos"; hardware = "laptop"; system = "x86_64-linux"; timezone = secrets.main_timezone; location = secrets.main_location; }
    { host = "luna"; hardware = "chromebook"; system = "x86_64-linux"; timezone = secrets.main_timezone; location = secrets.main_location; }
    { host = "vm"; hardware = "virtualbox"; system = "x86_64-linux"; timezone = secrets.main_timezone; location = secrets.main_location; }
  ];

  mkHost = { host, hardware, system, timezone, location }: extraModules: isNixOS: isIso: isHardware:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowBroken = true;
        };
        overlays = [
          inputs.nur.overlay
          (import ../packages)
          (import ../overlays)
        ];
      };
      extraArgs = { inherit pkgs inputs isIso isHardware user secrets timezone location; hostname = host; };
      #TODO: FIXME
      extraSpecialModules = if isIso then extraModules ++ [ "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ] else extraModules;
      megaSpecialModules = if isHardware then extraSpecialModules ++ [ ./${ host}/hardware/${hardware} ] else extraSpecialModules;
    in
    if isNixOS
    then
      nixpkgs.lib.nixosSystem
        {
          inherit system;
          specialArgs = extraArgs;
          modules = [
            ./configuration.nix
            ./${host}
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = extraArgs;
              home-manager.users.${user} = {
                imports = [
                  ./home.nix
                  ./${ host }/home.nix
                ];
              };
            }
          ] ++ megaSpecialModules;
        }
    else
      home-manager.lib.homeManagerConfiguration
        {
          inherit pkgs;
          extraSpecialArgs = extraArgs;
          modules = [
            ./home.nix
            ./${ host }/home.nix
          ];
        };
in
  /*
    We have a list of sets.
    Map each element of the list applying the mkHost function to its elements and returning a set in the listToAttrs format
    builtins.listToAttrs on the result
  */
builtins.listToAttrs (map ({ host, hardware, system, timezone, location }: { name = host; value = mkHost { inherit host hardware system timezone location; } extraModules isNixOS isIso isHardware; }) hosts)
