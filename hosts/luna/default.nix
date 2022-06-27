# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, secrets, hostname, inputs, user, ... }: {

  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
  ];

  services = {
    # Configure keymap in X11
    xserver.layout = "gb";
    fstrim.enable = true;
    logind.extraConfig = ''
      # don’t shutdown when power button is short-pressed
      HandlePowerKey=ignore
    '';
    udev.extraHwdb = ''
      evdev:name:AT Translated Set 2 keyboard:*
       KEYBOARD_KEY_3b=back
       KEYBOARD_KEY_3c=forward
       KEYBOARD_KEY_3d=refresh
       #KEYBOARD_KEY_3e=full_screen DOESNT CURRENTLY WORK WITH XORG (KEY_ZOOM)
       KEYBOARD_KEY_3f=switchvideomode
       KEYBOARD_KEY_40=brightnessdown
       KEYBOARD_KEY_41=brightnessup
       KEYBOARD_KEY_42=mute
       KEYBOARD_KEY_43=volumedown
       KEYBOARD_KEY_44=volumeup
       KEYBOARD_KEY_db=search
    '';
  };

  # Pick only one of the below networking options.
  networking = {
    wireless = {
      enable = true; # Enables wireless support via wpa_supplicant.
      networks = secrets.wifi;
    };
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  environment.systemPackages = with pkgs; [
    xf86_input_cmt #chromebook touchpad drivers
  ];

}

