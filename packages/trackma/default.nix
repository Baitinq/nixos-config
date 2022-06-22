{ pkgs, lib }:

pkgs.python39.pkgs.buildPythonApplication rec {
  pname = "trackma";
  version = "0.8.4";

  buildInputs = with pkgs; [ gobject-introspection gtk3 gnome.adwaita-icon-theme ];
  nativeBuildInputs = with pkgs; [ wrapGAppsHook ];
  propagatedBuildInputs = with pkgs.python39.pkgs; [ setuptools pygobject3 pycairo pillow ];

  #bug with fetchFromGithub?
  src = pkgs.fetchgit {
    url = "https://github.com/z411/trackma.git";
    rev = "934c567096bbe5104d6ad7a21014d04b1b198052";
    sha256 = "sha256-Es95F6TTPzHDt5sXLseV9gi8erDvmJEvlB0Kl1RPpB4=";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/z411/trackma";
    description = "Open multi-site list manager for Unix-like systems.";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
