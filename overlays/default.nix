final: prev: let
  overlays = [
    (import ./base)
  ];
in
  prev.lib.composeManyExtensions overlays final prev
