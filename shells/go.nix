{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "go-shell";
  buildInputs = with pkgs; [
    go
  ];
}
