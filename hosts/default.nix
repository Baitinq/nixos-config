{
  lib,
  inputs,
  secrets,
  dotfiles,
  hosts,
  hardwares,
  systems,
  isNixOS,
  isMacOS,
  isIso,
  isHardware,
  user,
  nixpkgs,
  home-manager,
  nix-darwin,
  ...
}: let
  mkHost = {
    host,
    hardware,
    stateVersion,
    system,
    timezone,
    location,
    extraOverlays,
    extraModules,
  }: isNixOS: isMacOS: isIso: isHardware: let
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        allowBroken = true;
        allowUnsupportedSystem = true;
      };
      overlays =
        [
          inputs.nur.overlays.default
          # inputs.neovim-nightly-overlay.overlay
          (import ../packages)
          (import ../overlays)
        ]
        ++ extraOverlays;
    };

    extraArgs = {
      inherit pkgs inputs isIso isHardware user secrets dotfiles timezone location hardware system stateVersion;
      hostname = host + "-" + hardware;
    };

    extraSpecialModules = extraModules ++ lib.optional isHardware ../hardware/${hardware} ++ lib.optional isIso "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
  in
    if isNixOS
    then
      nixpkgs.lib.nixosSystem
      {
        inherit system;
        specialArgs = extraArgs;
        modules =
          [
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
                  ./${host}/home.nix
                ];
              };
            }
            inputs.nix-index.nixosModules.nix-index
          ]
          ++ extraSpecialModules;
      }
    else if isMacOS
    then
      nix-darwin.lib.darwinSystem
      {
        inherit system;
        specialArgs = extraArgs;
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = extraArgs;
            home-manager.users."manuel.palenzuela" = {
              imports = [
                ./home-darwin.nix
              ];
            };
          }
        ];
      }
    else
      home-manager.lib.homeManagerConfiguration
      {
        inherit pkgs;
        extraSpecialArgs = extraArgs;
        modules = [
          ./home.nix
          ./${host}/home.nix
        ];
      };

  hardwarePermutatedHosts = lib.concatMap (hardware: map (host: host // hardware) hosts) hardwares;
  systemsPermutatedHosts = lib.concatMap (system: map (host: host // system) hardwarePermutatedHosts) systems;
  permutatedHosts = systemsPermutatedHosts;
in
  /*
  We have a list of sets.
  Map each element of the list applying the mkHost function to its elements and returning a set in the listToAttrs format
  builtins.listToAttrs on the result
  */
  builtins.listToAttrs (map (mInput @ {
      host,
      hardware,
      system,
      ...
    }: {
      name = host + "-" + hardware + "-" + system;
      value = mkHost mInput isNixOS isMacOS isIso isHardware;
    })
    permutatedHosts)
