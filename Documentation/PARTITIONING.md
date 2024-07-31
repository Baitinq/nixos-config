# Partitioning & Mounting

My NixOS configuration has some extra helpers for partitioning and mounting :)

These scripts live in your specific `hardware/$HARDWARE/disks.nix` (Which should be customized to fit your specific configuration).

### Creating disks

<!-- actually `sh`, but github nushell syntax highlighting is better -->
```nushell
nix run .#nixosConfigurations.$HOST-$HARDWARE-$ARCH.config.disks-create
```

### Formatting disks

```nushell
nix run .#nixosConfigurations.$HOST-$HARDWARE-$ARCH.config.disks-format
```

### Mounting disks

```nushell
nix run .#nixosConfigurations.$HOST-$HARDWARE-$ARCH.config.disks-mount
```
