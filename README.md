# NIX Config
My Personal NixOS Flake.
  

# NixOS
## Installing

```
nixos-install --flake . #$HOST-$HARDWARE-$ARCH
```

## Updating

```
nix flake update

nixos-rebuild switch --flake . #$HOST-$HARDWARE-$ARCH
```

# Non-Nixos
## Installing
```
nix build .#homeManagerConfigurations.$HOST-$HARDWARE-$ARCH.activationPackage
./result/activate
```

## Updating
```
home-manager switch --flake .#$HOST-$HARDWARE-$ARCH
```

# ISO
## Building
```
nix build .#isoConfigurations.$HOST-$HARDWARE-$ARCH.config.system.build.isoImage
```

# Deploying
```
# deploy -s .#$HOST-$HARDWARE-$ARCH --hostname $TARGET_IP
```
