{ stdenv, lib, fetchFromGitHub, bash }:
stdenv.mkDerivation {
  pname = "dwmbar";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "thytom";
    repo = "dwmbar";
    rev = "574f5703c558a56bc9c354471543511255423dc7";
    sha256 = "sha256-IrelZpgsxq2dnsjMdh7VC5eKffEGRbDkZmZBD+tROPs=";
  };
  patches = [ ../../patches/dwmbar.patch ];
  buildInputs = [ bash ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/bin/_dwmbar/modules
    cp -r modules $out/bin/_dwmbar/
    install config $out/bin/_dwmbar/config
    install bar.sh $out/bin/_dwmbar/bar.sh
    install dwmbar $out/bin/dwmbar
  '';
}
