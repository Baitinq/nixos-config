{ stdenv, lib, fetchFromGitHub, makeWrapper, bash, img2pdf, zathura }:
stdenv.mkDerivation {
  pname = "manga-cli";

  version = "1.0";

  src = fetchFromGitHub {
    owner = "7USTIN";
    repo = "manga-cli";
    rev = "a69fe935341eaf96618a6b2064d4dcb36c8690b5";
    sha256 = "sha256-AnpOEgOBt2a9jtPNvfBnETGtc5Q1WBmSRFDvQB7uBE4=";
  };

  buildInputs = [ bash ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 ./manga-cli "$out/bin/manga-cli"
    wrapProgram $out/bin/manga-cli \
      --prefix PATH : ${lib.makeBinPath [ bash img2pdf zathura ]}
  '';

  meta = with lib; {
    homepage = "https://github.com/7USTIN/manga-cli";
    description = "Bash script for reading mangas via the terminal by scraping manganato";
    license = licenses.gpl3;
    maintainers = with maintainers; [ baitinq ];
    platforms = platforms.unix;
  };
}
