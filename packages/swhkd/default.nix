{ rustPlatform, fetchFromGitHub, pkgs, ... }:
rustPlatform.buildRustPackage rec {
  name = "swhkd";

  nativeBuildInputs = with pkgs; [
    pkgconfig
  ];

  buildInputs = with pkgs; [ systemd ];

  src = fetchFromGitHub {
    owner = "waycrate";
    repo = name;
    rev = "2e6f091817be5f6ebf837f8fc1cdf1e54f0b3526";
    sha256 = "sha256-6kTRAUP///EwIkF1QkQByHqHW55u2L2Gv3c+B5z3e5U=";
  };

  cargoHash = "sha256-E5AE18CfeX1HI/FbGDFoUDsPyG/CpJrD+8Ky7c+EQUw=";
}
