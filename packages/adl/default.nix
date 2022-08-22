{ stdenv, lib, fetchFromGitHub, makeWrapper, bash, anime-downloader, trackma, mpv, fzf, perl }:
stdenv.mkDerivation {
  pname = "adl";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "RaitaroH";
    repo = "adl";
    rev = "65f68e1dcae4c0caa52668d3a854269e7d226f7c";
    sha256 = "sha256-huGpDtkWrhZyKDNKXat8T3qtAyMjBaq8HFd1w1ThUVk=";
  };
  buildInputs = [ bash ];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp adl $out/bin/adl  
    wrapProgram $out/bin/adl \
      --prefix PATH : ${lib.makeBinPath [ bash anime-downloader trackma mpv fzf perl ]}
  '';
}
