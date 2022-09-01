{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation {
  pname = "dwmbar";
  version = "1.0";
  
  src = fetchFromGitHub {
    owner = "thytom";
    repo = "dwmbar";
    rev = "574f5703c558a56bc9c354471543511255423dc7";
    sha256 = "sha256-IrelZpgsxq2dnsjMdh7VC5eKffEGRbDkZmZBD+tROPs=";
  };
  
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/config
    cp -r modules/ $out/config/
    install config $out/config/config
    install bar.sh $out/config/bar.sh
    substituteInPlace dwmbar --replace 'DEFAULT_CONFIG_DIR="/usr/share/dwmbar"' "DEFAULT_CONFIG_DIR=\"$out/config\""
    install dwmbar $out/bin/dwmbar
  '';
}
