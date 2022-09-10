final: prev:
{
  custom = {
    adl = prev.callPackage ./adl { };
    kindlegen = prev.callPackage ./kindlegen { };
    xmonadctl = prev.callPackage ./xmonadctl { };
    lemacs = prev.callPackage ./lemacs { };
  };
}
