final: prev:
{
  custom = {
    smart-wallpaper = prev.callPackage ./smart-wallpaper { };
    dwmbar = prev.callPackage ./dwmbar { };
    trackma = prev.callPackage ./trackma { };
    anime-downloader = prev.callPackage ./anime-downloader { pkgs = prev; };
    adl = prev.callPackage ./adl { anime-downloader = final.custom.anime-downloader; trackma = final.custom.trackma; };
    kindlegen = prev.callPackage ./kindlegen { };
  };
}
