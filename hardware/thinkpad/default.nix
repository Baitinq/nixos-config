{ pkgs, ... }:
{
  imports = [ ./hardware.nix ];

  # nvramtool settings:
  #
  # fn_ctrl_swap = Enable
  # wwan = Disable
  # me_state = Disable
  # gfx_uma_size = 128M

  environment.systemPackages = with pkgs; [
    flashrom
    nvramtool
  ];
}
