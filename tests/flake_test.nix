let
  flake = import ../flake.nix;
in
[
  {
    name = "home-manger should follow nixpkgs";
    actual = flake.inputs.home-manager.inputs.nixpkgs.follows;
    expected = "nixpkgs";
  }
]
