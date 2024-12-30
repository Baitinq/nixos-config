{
  pkgs,
  user,
  ...
}: {
  users.users."${user}".home = "/Users/${user}";

  environment.systemPackages = with pkgs; [
    neovim-nightly
    ripgrep
    fd
    tmux
    yt-dlp
    pfetch
    fzf
    comma
    moreutils
  ];

  services.nix-daemon.enable = true;
}
