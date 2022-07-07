{ config, pkgs, ... }: {
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "InconsolataLGC" "Noto" ]; })
  ];
}
