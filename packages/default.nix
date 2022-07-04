final: prev:
{
  custom = {
    smart-wallpaper = prev.callPackage ./smart-wallpaper { };
    dwmbar = prev.callPackage ./dwmbar { };
    trackma = prev.callPackage ./trackma { };
    adl = prev.callPackage ./adl { inherit (final.custom) trackma; };
    kindlegen = prev.callPackage ./kindlegen { };
    manga-cli = prev.callPackage ./manga-cli { };
    mov-cli = prev.callPackage ./mov-cli { };
    xmonadctl = prev.callPackage ./xmonadctl { };
  };
}
