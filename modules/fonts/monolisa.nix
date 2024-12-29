{
  lib,
  requireFile,
  unzip,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "monolisa";
  version = "1";

  src = ../../secrets/monolisa.zip;

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
    install -m444 -Dt $out/share/fonts/opentype/monolisa monolisa/*.ttf
  '';

  meta = {
    description = "Monolisa Typeface";
    homepage = "https://monolisa.dev";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
})
