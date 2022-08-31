# Partition and mount disks
```
nix run .#nixosConfigurations.HOST.config.disks-create
nix run .#nixosConfigurations.HOST.config.disks-mount
```

# Install nixos
nixos-install --flake .#HOST
