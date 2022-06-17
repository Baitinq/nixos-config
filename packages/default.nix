final: prev:
{
  custom.smart-wallpaper = prev.callPackage ./smart-wallpaper { };
  custom.dwmbar = prev.callPackage ./dwmbar { };
  custom.xwinwrapr = prev.callPackage ./xwinwrap { };
  custom.adl = prev.callPackage ./adl { };
  custom.anime-downloader = prev.callPackage ./anime-downloader { pkgs = prev; };
}
