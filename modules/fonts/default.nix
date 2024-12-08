{ config, pkgs, ... }: {
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nerd-fonts.inconsolata-lgc
    nerd-fonts.noto
  ];
}
