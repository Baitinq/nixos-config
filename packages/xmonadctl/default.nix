{ writers, haskellPackages, ... }:
writers.writeHaskellBin "xmonadctl"
{
  libraries = [ haskellPackages.xmonad-contrib haskellPackages.X11 ];
}
  (builtins.readFile ./xmonadctl.hs)
