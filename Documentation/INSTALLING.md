# Installing

My NixOS configuration is modular by design. In practice, this means that you can build a NixOS configuration for your own machine by selecting any combination of these 3 variables:

---
`$HOST` -> this refers to the host-specific configuration (packages, services, etc). This loads the host-specific configuration from `/hosts/$HOST/default.nix`

`$HARDWARE` -> this refers to the hardware-specific configuration (disks, kernel, boot, etc). This loads the hardware-specific configuration from `/hosts/$HARDWARE/default.nix`

`$ARCH` -> this refers to the architecture of the configuration (x86_64-linux, aarch64-darwin, etc). This sets the architecture to use for the packages.

---

An example complete configuration could be: `phobos-laptop-x86_64-linux` [This is my personal laptop configuration :)]

All these variables are declared in the `flake.nix` and can be added/removed to fit your needs.


# Installation Steps
Make sure you're in the `nixos-config` folder and have followed (if necessary) the [partitioning steps](PARTITIONING.md) :)
## NixOS-Based Intallation
### Installing

```
$ nixos-install --flake .#$HOST-$HARDWARE-$ARCH
```

### Updating

```
$ nix flake update

$ nixos-rebuild switch --flake .#$HOST-$HARDWARE-$ARCH
```

## Non-Nixos-Based Installation
### Installing
```
$ nix build .#homeManagerConfigurations.$HOST-$HARDWARE-$ARCH.activationPackage
$ ./result/activate
```

### Updating
```
$ nix flake update

$ home-manager switch --flake .#$HOST-$HARDWARE-$ARCH
```

## ISO
### Building
```
$ nix build .#isoConfigurations.$HOST-$HARDWARE-$ARCH.config.system.build.isoImage
```

## Deploying
```
# deploy -s .#$HOST-$HARDWARE-$ARCH --hostname $TARGET_IP
```

## Testing
```
$ nix eval .#tests
```
