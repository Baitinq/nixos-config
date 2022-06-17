{ config, lib, pkgs, inputs, user, hostname, secrets, ... }:
{
  home.packages = with pkgs; [
    (minecraft.override { jre = pkgs.jdk8; })
    jetbrains.idea-community
    calibre
    qtcreator
  ];
}
