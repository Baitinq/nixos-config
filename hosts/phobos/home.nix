{ config, lib, pkgs, inputs, user, hostname, secrets, ... }:
{
  home.packages = with pkgs; [
    minecraft
    jetbrains.idea-community
    calibre
    qtcreator
    custom.anime-downloader
    custom.adl
    custom.trackma
    custom.kindlegen
    kcc
  ];
}
