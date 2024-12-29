{
  lib,
  requireFile,
  unzip,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tx-02";
  version = "1";

  src = ../../secrets/tx-02.zip;

  outputs = [
    "out"
  ];

  nativeBuildInputs = [
    unzip
  ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    install -m444 -Dt $out/share/fonts/opentype/tx-02 TX-02/*.otf
  '';

  meta = {
    description = "Berkeley Mono TX-02 Typeface";
    homepage = "https://berkeleygraphics.com/typefaces/berkeley-mono";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
})
