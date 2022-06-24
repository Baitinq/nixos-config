final: prev:
{
  custom = {
    smart-wallpaper = prev.callPackage ./smart-wallpaper { };
    dwmbar = prev.callPackage ./dwmbar { };
    trackma = prev.callPackage ./trackma { };
    anime-downloader = prev.callPackage ./anime-downloader { };
    adl = prev.callPackage ./adl { inherit (final.custom) anime-downloader trackma; };
    kindlegen = prev.callPackage ./kindlegen { };
  };
}
