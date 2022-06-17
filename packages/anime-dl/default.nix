{ pkgs
, lib
, fetchFromGitHub
, python3Packages
, python3
, extraPkgs ? pkgs: [ ]
}:
python3Packages.buildPythonApplication rec {
  pname = "anime-dl";
  version = "5.0.14";
  src = fetchFromGitHub {
    owner = "anime-dl";
    repo = "anime-downloader";
    rev = version;
    sha256 = "1ai71g8cp2i37p53lm32nl3h8cq7rcxifhnj1z1cfvxbqjvackaj";
  };

  propagatedBuildInputs = with python3.pkgs; [
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
  ] ++ extraPkgs pkgs;

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/anime-dl/anime-downloader";
    description = "A simple but powerful anime downloader and streamer.";
    license = licenses.unlicense;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}

