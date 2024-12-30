{
  fetchurl,
  lib,
  stdenv,
  unzip,
}: let
  version = "2.9";
  fileVersion = builtins.replaceStrings ["."] ["_"] version;

  sha256 =
    {
      x86_64-linux = "sha256-2ZLFM5YcV2Ym38hxU8WMrRDjHDF6edqYohLeM+ASgpk=";
    }
    .${stdenv.hostPlatform.system}
    or (throw "system #{stdenv.hostPlatform.system.} is not supported");

  url =
    {
      x86_64-linux = "https://archive.org/download/kindlegen_linux_2_6_i386_v2_9/kindlegen_linux_2.6_i386_v2_9.tar.gz";
    }
    .${stdenv.hostPlatform.system}
    or (throw "system #{stdenv.hostPlatform.system.} is not supported");
in
  stdenv.mkDerivation {
    pname = "kindlegen";
    inherit version;

    src = fetchurl {
      inherit url;
      inherit sha256;
    };

    sourceRoot = ".";

    nativeBuildInputs = lib.optional (lib.hasSuffix ".zip" url) unzip;

    installPhase = ''
      mkdir -p $out/bin $out/share/kindlegen/doc
      install -m755 kindlegen $out/bin/kindlegen
      cp -r *.txt *.html docs/* $out/share/kindlegen/doc
    '';

    meta = with lib; {
      description = "Convert documents to .mobi for use with Amazon Kindle";
      homepage = "https://www.amazon.com/gp/feature.html?docId=1000765211";
      license = licenses.unfree;
      maintainers = with maintainers; [peterhoeg];
      platforms = ["x86_64-linux" "i686-linux" "x86_64-darwin" "i686-darwin" "x86_64-cygwin" "i686-cygwin"];
    };
  }
