{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "lua-shell";
  buildInputs = with pkgs; [
    lua
  ];
}