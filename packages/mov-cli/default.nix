{ lib, python39, fetchgit, gobject-introspection, gtk3, gnome, wrapGAppsHook }:

python39.pkgs.buildPythonApplication rec {
  pname = "mov-cli";
  version = "1.0";

  propagatedBuildInputs = with python39.pkgs; [ setuptools httpx click beautifulsoup4 colorama ];

  #bug with fetchFromGithub?
  src = fetchgit {
    url = "https://github.com/mov-cli/${pname}.git";
    rev = "b89e807e8ffc830b0b18c8e98712441c03774b8e";
    sha256 = "sha256-D+OeXcLdkbG4ASbPQYIWf7J1CRZ9jH3UXxfTL4WleY0=";
  };

  prePatch = ''
    substituteInPlace setup.py \
    --replace "bs4" "beautifulsoup4"
  '';

  doCheck = false;
}
