# Generated (not redistributed) GSP-boot assets for gpu-unlock, built from
# pinned NVIDIA 610.43.03 inputs exactly like upstream's `make assets`.
{
  lib,
  stdenvNoCC,
  callPackage,
  fetchurl,
  python3,
  zstd,
  gnutar,
  xz,
  gnumake,
}: let
  nvVersion = "610.43.03";
  nvSource = fetchurl {
    url = "https://download.nvidia.com/XFree86/NVIDIA-kernel-module-source/NVIDIA-kernel-module-source-610.43.03.tar.xz";
    sha256 = "7e118923c7a23edc36114d63273a46e3e04e9af98695a42203e7ac2dfe9fc1dc";
  };
  nvUtils = fetchurl {
    url = "https://archive.cachyos.org/archive/cachyos-v3/nvidia-utils-610.43.03-1-x86_64_v3.pkg.tar.zst";
    sha256 = "e17e7c92eeffa178b0fe1f40eb17a47095f8fc3ce4a77bf115cf5bd5a4df86e9";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "gpu-unlock-firmware";
    version = nvVersion;
    src = callPackage ./source.nix {};

    nativeBuildInputs = [python3 zstd gnutar xz gnumake];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      mkdir -p assets assets.src
      tar -xf ${nvSource} -C assets.src
      python3 firmware/generate_v67.py ${nvUtils} assets
      python3 firmware/extract_boot_assets.py assets.src/NVIDIA-kernel-module-source-${nvVersion} assets
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      make install-firmware ASSETS=assets DESTDIR=$out \
        FWDIR=/lib/firmware/gpu-unlock/${nvVersion} LICENSEDIR=/share/licenses
      runHook postInstall
    '';

    meta = {
      description = "Generated GSP boot assets for gpu-unlock (Ampere tensor-core unlock)";
      homepage = "https://github.com/Zagitta/gpu-unlock";
      platforms = ["x86_64-linux"];
      license = lib.licenses.unfree;
    };
  }
