# NIX Config
My Personal NixOS Flake.
  

# NixOS
## Installing

```
nixos-install --flake . #HOST
```

## Updating

```
nix flake update

nixos-rebuild switch --flake . #HOST
```

# Non-Nixos
## Installing
```
nix build .#homeManagerConfigurations.HOST.activationPackage
./result/activate
```

## Updating
```
home-manager switch --flake .#HOST
```

# ISO
## Building
```
nix build .#nixosConfigurations.HOST.config.system.build.isoImage
```
