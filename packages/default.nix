final: prev:
{
  custom = {
    kindlegen = prev.callPackage ./kindlegen { };
    lemacs = prev.callPackage ./lemacs { };
    animdl = prev.callPackage ./animdl { };
  };
}
