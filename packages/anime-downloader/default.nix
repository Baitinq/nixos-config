{ pkgs, lib }:

pkgs.python39.pkgs.buildPythonPackage rec {
  pname = "anime-downloader";
  version = "5.0.14";

  src = pkgs.fetchFromGitHub {
    owner = "anime-dl";
    repo = "anime-downloader";
    rev = version;
    sha256 = "1ai71g8cp2i37p53lm32nl3h8cq7rcxifhnj1z1cfvxbqjvackaj";
  };

  propagatedBuildInputs = with pkgs.python39.pkgs; [
    pySmartDL
    cfscrape
    beautifulsoup4
    requests
    requests-cache
    click
    fuzzywuzzy
    coloredlogs
    tabulate
    pycryptodome

    pkgs.nodejs
    pkgs.mpv
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/anime-dl/anime-downloader";
    description = "A simple but powerful anime downloader and streamer.";
    license = licenses.unlicense;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
