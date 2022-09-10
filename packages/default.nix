final: prev:
{
  custom = {
    kindlegen = prev.callPackage ./kindlegen { };
    lemacs = prev.callPackage ./lemacs { };
  };
}
