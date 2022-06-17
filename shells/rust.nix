{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "rust-shell";
  buildInputs = with pkgs; [
    cargo
  ];
}
