final: prev:
{
  custom.smart-wallpaper = prev.callPackage ./smart-wallpaper { };
  custom.dwmbar = prev.callPackage ./dwmbar { };
  custom.xwinwrap = prev.callPackage ./xwinwrap { };
  custom.trackma = prev.callPackage ./trackma { };
  custom.anime-downloader = prev.callPackage ./anime-downloader { pkgs = prev; };
  custom.adl = prev.callPackage ./adl { anime-downloader = final.custom.anime-downloader; trackma = final.custom.trackma; };
  custom.kindlegen = prev.callPackage ./kindlegen { };
}
