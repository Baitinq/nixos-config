{
  lib,
  requireFile,
  unzip,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "berkeley-mono";
  version = "1";

  src = ../../secrets/berkeley-mono.zip;

  outputs = [
    "out"
    "web"
    "variable"
    "variableweb"
  ];

  nativeBuildInputs = [
    unzip
  ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    install -m444 -Dt $out/share/fonts/truetype/berkeley-mono berkeley-mono/TTF/*.ttf
    install -m444 -Dt $out/share/fonts/opentype/berkeley-mono berkeley-mono/OTF/*.otf
    install -m444 -Dt $web/share/fonts/webfonts/berkeley-mono berkeley-mono/WEB/*.woff2
    install -m444 -Dt $variable/share/fonts/truetype/berkeley-mono berkeley-mono-variable/TTF/*.ttf
    install -m444 -Dt $variableweb/share/fonts/webfonts/berkeley-mono berkeley-mono-variable/WEB/*.woff2
  '';

  meta = {
    description = "Berkeley Mono Typeface";
    homepage = "https://berkeleygraphics.com/typefaces/berkeley-mono";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
})
