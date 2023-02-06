# Partition and mount disks
```
nix run .#nixosConfigurations.$HOST-$HARDWARE-$ARCH.config.disks-create
nix run .#nixosConfigurations.$HOST-$HARDWARE-$ARCH.config.disks-format
nix run .#nixosConfigurations.$HOST-$HARDWARE-$ARCH.config.disks-mount
```

# Install nixos
nixos-install --flake .#HOST
