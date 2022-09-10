final: prev:
{
  custom = {
    smart-wallpaper = prev.callPackage ./smart-wallpaper { };
    adl = prev.callPackage ./adl { };
    kindlegen = prev.callPackage ./kindlegen { };
    manga-cli = prev.callPackage ./manga-cli { };
    mov-cli = prev.callPackage ./mov-cli { };
    xmonadctl = prev.callPackage ./xmonadctl { };
    lemacs = prev.callPackage ./lemacs { };
  };
}
