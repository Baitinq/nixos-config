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
}
