let
  lib = import ./lib.nix;
in [
  {
    name = "Test function concatenate";
    actual = lib.concatenate "a" "b";
    expected = "ab";
  }
  {
    name = "Test function add";
    actual = lib.add 1 2;
    expected = 3;
  }
]
