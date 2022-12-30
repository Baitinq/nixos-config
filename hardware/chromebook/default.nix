{ ... }:
{
  imports = [
    ./hardware.nix

    ../../modules/power-save
    ../../modules/bluetooth
  ];
}
