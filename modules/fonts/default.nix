{
  config,
  pkgs,
  ...
}: {
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.inconsolata-lgc
      nerd-fonts.noto
      (pkgs.callPackage ./berkeley-mono.nix {})
      (pkgs.callPackage ./tx-02.nix {})
      (pkgs.callPackage ./monolisa.nix {})
    ];
    fontconfig = {
      defaultFonts = {
        monospace = ["TX-02" "Inconsolata LGC"];
      };
    };
  };
}
