{ stdenv, lib, fetchFromGitHub, makeWrapper, bash, xdpyinfo, killall, xwinwrap }:
stdenv.mkDerivation {
  pname = "smart-wallpaper";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "Baitinq";
    repo = "smart-wallpaper";
    rev = "154acddeb4b63c19beacc6a68248dd02797d9cca";
    sha256 = "sha256-fRK3N+UnBPXpvx4Z64JC5TstUi//l5jtrm+rFDxIQUs=";
  };
  buildInputs = [ bash ];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp smart-wallpaper $out/bin/smart-wallpaper  
    wrapProgram $out/bin/smart-wallpaper \
      --prefix PATH : ${lib.makeBinPath [ bash xdpyinfo killall xwinwrap ]}
  '';
}
