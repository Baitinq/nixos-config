{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "c*-shell";
  buildInputs = with pkgs; [
    gdb
    valgrind
    gcc
    clang
    cmake
    ninja
  ];
}
