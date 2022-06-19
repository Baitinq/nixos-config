final: prev:
let
  overlays = [
    (import ./base.nix)
  ];
in
prev.lib.composeManyExtensions overlays final prev
