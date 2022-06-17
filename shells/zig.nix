{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "zig-shell";
  buildInputs = with pkgs; [
    zig
  ];
}