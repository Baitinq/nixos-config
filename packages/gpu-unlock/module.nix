{
  lib,
  stdenv,
  callPackage,
  kernel,
  kernelModuleMakeFlags,
}:
stdenv.mkDerivation {
  pname = "gpu-unlock";
  version = "0-unstable-${kernel.version}";
  src = callPackage ./source.nix {};

  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = ["pic" "format"];

  makeFlags =
    kernelModuleMakeFlags
    ++ [
      "-C"
      "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "M=$(NIX_BUILD_TOP)/source/kernel/gpu_unlock"
      "INSTALL_MOD_PATH=${placeholder "out"}"
      "INSTALL_MOD_DIR=extra"
      "DEPMOD=true"
    ];
  buildFlags = ["modules"];
  installTargets = ["modules_install"];

  meta = {
    description = "Unlock full-rate tensor-core throughput on GeForce Ampere GPUs";
    homepage = "https://github.com/Zagitta/gpu-unlock";
    platforms = ["x86_64-linux"];
    license = lib.licenses.gpl2Only;
  };
}
