{ config, pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.inconsolata-lgc
      nerd-fonts.noto
      (pkgs.callPackage ./berkeley-mono {})
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "Berkeley Mono" "Inconsolata LGC" ];
      };
    #   localConf = ''
    #   <?xml version="1.0"?>
    #   <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    #   <fontconfig>
    #      <match target="pattern">
    #         <test qual="any" name="family" compare="eq"><string>Berkeley Mono</string></test>
    #         <edit name="family" mode="assign" binding="same"><string>Inconsolata LGC</string></edit>
    #      </match>
    #   </fontconfig>
    # '';
    };
  };
}
