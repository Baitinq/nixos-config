final: prev:
{
  custom = {
    smart-wallpaper = prev.callPackage ./smart-wallpaper { };
    adl = prev.callPackage ./adl { };
    kindlegen = prev.callPackage ./kindlegen { };
    xmonadctl = prev.callPackage ./xmonadctl { };
    lemacs = prev.callPackage ./lemacs { };
  };
}
