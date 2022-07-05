{ writers, haskellPackages, ... }:
writers.writeHaskellBin "xmonadctl"
{
  libraries = [ haskellPackages.xmonad-contrib haskellPackages.X11 ];
}
  (builtins.readFile (builtins.fetchurl {
    url = "https://raw.githubusercontent.com/xmonad/xmonad-contrib/6ab136eb5606ddec0735bda0be5b82785494a409/scripts/xmonadctl.hs";
    sha256 = "sha256:04453qq1vvm5s9hmaq60krpca856z0ch1fs2y7hy7wdp3wm17pym";
  }))
