# NIX Config
My Personal NixOS Flake.
  
## Installing

```
nixos-install --flake . #HOST
```

## Updating

```
nix flake update

nixos-rebuild switch --flake . #HOST
```