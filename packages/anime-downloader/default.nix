{ python39, fetchFromGitHub, nodejs, mpv, lib }:

python39.pkgs.buildPythonPackage rec {
  pname = "anime-downloader";
  version = "5.0.14";

  src = fetchFromGitHub {
    owner = "anime-dl";
    repo = "anime-downloader";
    rev = version;
    sha256 = "1ai71g8cp2i37p53lm32nl3h8cq7rcxifhnj1z1cfvxbqjvackaj";
  };

  propagatedBuildInputs = with python39.pkgs; [
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

    nodejs
    mpv
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
