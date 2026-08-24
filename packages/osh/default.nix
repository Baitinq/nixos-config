{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "osh";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Baitinq";
    repo = "osh";
    rev = "82655fa09a2bc8766345eb604683094d3435e396";
    hash = "sha256-uxSrRC9vlAdBWbpYae3jybdppFW8OrkBRWwqi6GXnmg=";
  };

  modRoot = "src";

  vendorHash = "sha256-unERoSLhBWFaL1f/L0Siy+PxxRxEm/Asf+ankt2W/DI=";

  subPackages = [ "cmd/osh" ];

  meta = with lib; {
    description = "Overly Simple Harness - a small terminal-based OpenAI agent with shell access";
    homepage = "https://github.com/baitinq/osh";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "osh";
  };
}
