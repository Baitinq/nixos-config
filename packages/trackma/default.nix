{ lib, python39, fetchgit, gobject-introspection, gtk3, gnome, wrapGAppsHook }:

python39.pkgs.buildPythonApplication rec {
  pname = "trackma";
  version = "0.8.4";

  buildInputs = [ gobject-introspection gtk3 gnome.adwaita-icon-theme ];
  nativeBuildInputs = [ wrapGAppsHook ];
  propagatedBuildInputs = with python39.pkgs; [ setuptools pygobject3 pycairo pillow ];

  #bug with fetchFromGithub?
  src = fetchgit {
    url = "https://github.com/z411/${pname}.git";
    rev = "v" + version;
    sha256 = "sha256-OoPnOqq2havXc726nXpvoO00BEnjauw8zdXYDltBbsg=";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/z411/${pname}";
    description = "Trackma aims to be a lightweight and simple but feature-rich program for Unix based systems for fetching, updating and using data from personal lists hosted in several media tracking websites.";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
