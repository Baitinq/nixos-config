{ pkgs, ... }:
{
  imports = [ ./hardware.nix ];

  # nvramtool settings:
  #
  # fn_ctrl_swap = Enable
  # wwan = Disable
  # me_state = Disable
  # gfx_uma_size = 128M

  # ectool battery threshold setting (84%):
  #
  # ectool -w 0xb1 -z 0x54

  environment.systemPackages = with pkgs; [
    flashrom
    nvramtool
    intelmetool
    ectool
    cbmem
  ];

}
