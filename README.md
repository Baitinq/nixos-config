# NIX Config
My Personal NixOS Flake.
  

# NixOS
## Installing

```
nixos-install --flake . #HOST-HARDWARE
```

## Updating

```
nix flake update

nixos-rebuild switch --flake . #HOST-HARDWARE
```

# Non-Nixos
## Installing
```
nix build .#homeManagerConfigurations.HOST-HARDWARE.activationPackage
./result/activate
```

## Updating
```
home-manager switch --flake .#HOST-HARDWARE
```

# ISO
## Building
```
nix build .#isoConfigurations.HOST-HARDWARE.config.system.build.isoImage
```
