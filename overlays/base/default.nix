final: prev:
{
  dwm = prev.dwm.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "Baitinq";
      repo = "dwm";
      rev = "79e2e3b31c3dc0e410394006196201d5ec9ae7c5";
      sha256 = "sha256-jcfcOEQTdAw/4yFmHO3MtXjhcxNnNpqJgjuxy0T8zIs=";
    };
  });

  dmenu = prev.dmenu.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "Baitinq";
      repo = "dmenu";
      rev = "4935902378d321c465f5f8ec18619b22da75527b";
      sha256 = "sha256-MyNMxdaWtgjClZGIHUtYwwx51u5NII5Ce4BnOnUojo8=";
    };

    patches = [ ./patches/dmenu_height.patch ];
  });

  st = prev.st.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ prev.harfbuzz ];
    src = prev.fetchFromGitHub {
      owner = "LukeSmithxyz";
      repo = "st";
      rev = "3144a61c180b678f6b1c23f06e4b434090199fcb";
      sha256 = "sha256-J5JwuQMdDU4Oy7let0IYA2rwOZD057LEE+sOmmGCkqc=";
    };
  });

  minecraft = prev.minecraft.override { jre = prev.jdk8; };

  xwinwrap = prev.xwinwrap.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "Baitinq";
      repo = "xwinwrap";
      rev = "401b5a5eb092173443253cdd57736cd6bf401e40";
      sha256 = "sha256-8+asreFjzD49O3sZlAXBsWD3PU0rqkbs/J3Dq9VeiYA=";
    };
    buildPhase = "make all";
    installPhase = ''
      mkdir -p $out/bin
      mv xwinwrap $out/bin/xwinwrap
    '';
  });

  kcc = prev.kcc.overrideAttrs (oldAttrs: {
    version = "5.5.2";
    src = prev.fetchFromGitHub {
      owner = "ciromattia";
      repo = "kcc";
      rev = "4ec4c9966c727d6dac44507d34607bd7d2c5ed5c";
      sha256 = "sha256-vH3Cz7nL+sStogcCRLcN30Iap25f5hylXHECX52G4f0=";
    };
    patches = [
      ./patches/kcc.patch
      (prev.fetchpatch
        {
          url = "https://github.com/Baitinq/kcc/commit/73cd0dd107901bebe7d72e2b86ecf8b830a19758.diff";
          sha256 = "sha256-UsWTwujCmKsFrPUHIx8O8ELHpXFQdEbBRZh5SbPPWBM=";
        })
    ];
  });

  comma = prev.comma.overrideAttrs (old: rec {
    src = prev.fetchFromGitHub {
      owner = "baitinq";
      repo = "comma";
      rev = "1eeccb3c60323a292ddb44647f603d3a54005350";
      sha256 = "sha256-yT9eZSSSlAty9QcUtxVG4J3rWi5rxQMHAxbSGe9FQi0=";
    };
    cargoDeps = old.cargoDeps.overrideAttrs (prev.lib.const {
      inherit src;
      outputHash = "sha256-JDMu3ORns3lfIT9wmwKTUmn2DQPlasymTW4lkCpGFBY=";
    });
  });

  mpv = prev.wrapMpv prev.mpv-unwrapped {
    scripts = [ prev.mpvScripts.mpris ];
  };

  emacsPackagesFor = emacs: ((prev.emacsPackagesFor emacs).overrideScope' (prev: final: rec {
    manualPackages = final.manualPackages // { custom.lsp-bridge = prev.callPackage ../../packages/lsp-bridge { }; };
  }));

}
