{  pkgs, stateVersion, lib, dotfiles, user, ... }:
{
  imports = [
  ];

  home = {
    username = "${user}";
    homeDirectory = "/Users/${user}";

    packages = with pkgs; [
      git-crypt
    ];
  };

  services = {
  };

  programs = {
    emacs = {
      enable = true;
      extraPackages = epkgs: with epkgs; [
        use-package

        direnv

        evil
        evil-collection

        doom-modeline
        dashboard

        projectile
        lsp-ui

        lsp-bridge
        rust-mode
        rustic
        company
        flycheck
        lsp-haskell

        nix-mode
        haskell-mode
        typescript-mode
        jq-mode

        doom-themes

        dired-sidebar
      ];
      extraConfig = builtins.readFile "${dotfiles}/.emacs";
    };
  };

  home.stateVersion = stateVersion;
}
