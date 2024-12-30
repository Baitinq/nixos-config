{...}: {
  imports = [./hardware.nix];

  boot.loader.timeout = 5;
}
