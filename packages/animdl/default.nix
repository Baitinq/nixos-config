{ lib
, pkgs
, callPackage
, fetchFromGitHub
}:

pkgs.python39.pkgs.buildPythonPackage rec {
  pname = "animdl";
  version = "TODO";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "justfoolingaround";
    repo = "animdl";
    rev = "bb3701ec8ae0ee5d4606121d310f9b3922e29cb4";
    hash = "sha256-OOBxpVXadtTLd45i3aJRzUy1TZKF+ImKu/tzz15ih/A=";
  };

  propagatedBuildInputs = with pkgs.python39.pkgs; [
    poetry-core
    tqdm
  ];

  meta = with lib; {
    description = "Self-contained cryptographic library";
    homepage = "https://github.com/Legrandin/pycryptodome";
    license = with licenses; [ bsd2 /* and */ asl20 ];
    maintainers = with maintainers; [ fab ];
  };
}
