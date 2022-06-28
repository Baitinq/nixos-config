{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "haskell-shell";
  buildInputs = with pkgs; [
    ghc
    cabal-install
  ];
}
