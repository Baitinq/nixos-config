{ stdenv, lib, fetchFromGitHub, makeWrapper, bash, anime-dl, trackma, mpv, fzf }:
stdenv.mkDerivation {
  pname = "adl";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "RaitaroH";
    repo = "adl";
    rev = "65f68e1dcae4c0caa52668d3a854269e7d226f7c";
    sha256 = "sha256-fRK3N+UnBPXpvx4Z64JC5TstUi//x5jtrm+rFDxIQUs=";
  };
  buildInputs = [ bash anime-dl trackma mpv fzf ];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp adl $out/bin/adl  
    wrapProgram $out/bin/adl \
      --prefix PATH : ${lib.makeBinPath [ bash anime-dl trackma mpv fzf ]}
  '';
}
