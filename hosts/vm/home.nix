{ config, lib, pkgs, inputs, user, hostname, secrets, ... }:
{
  home.packages = with pkgs; [
    #jetbrains.idea-community
    #qtcreator
  ];
}
