final: prev: {
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
      rev = "6f11b0e8c1a5fa2be1bd83820ccd8569dd2b5fa2";
      sha256 = "sha256-DLuri86CMw4+3qznfskYFloCJae0eXExDpoQ4D8GpjA=";
    };
    NIX_CFLAGS_COMPILE = "-lXrender -lm";
    patches = [./patches/dmenu_height.patch];
  });

  st = prev.st.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [prev.harfbuzz];
    src = prev.fetchFromGitHub {
      owner = "LukeSmithxyz";
      repo = "st";
      rev = "3144a61c180b678f6b1c23f06e4b434090199fcb";
      sha256 = "sha256-J5JwuQMdDU4Oy7let0IYA2rwOZD057LEE+sOmmGCkqc=";
    };
  });

  # minecraft now in packages/minecraft

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

  mpv = prev.mpv.override {
    scripts = [prev.mpvScripts.mpris];
  };

  git-crypt = prev.git-crypt.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./patches/git-crypt-worktrees.patch];
  });

  emacs = prev.symlinkJoin {
    inherit (prev.emacs) name;
    inherit (prev.emacs) version;
    paths = [prev.emacs];
    nativeBuildInputs = [prev.makeBinaryWrapper];
    postBuild = "wrapProgram $out/bin/emacs --prefix PATH : ${prev.lib.makeBinPath [prev.nodejs prev.ripgrep]}";
  };

  neovim = prev.symlinkJoin {
    inherit (prev.neovim) name;
    inherit (prev.neovim) version;
    paths = [prev.neovim];
    nativeBuildInputs = [prev.makeBinaryWrapper];
    postBuild = "wrapProgram $out/bin/nvim --prefix PATH : ${prev.lib.makeBinPath [prev.nodejs prev.fd prev.ripgrep prev.fswatch]}";
  };
}
