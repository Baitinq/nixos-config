{ secrets, lib, pkgs, config, hostname, inputs, user, ... }: {

  imports = [
    ../modules/doas
    ../modules/pipewire
    ../modules/xorg
    ../modules/fonts
    ../modules/virtualisation
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.splashImage = null;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.timeout = 0;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  networking.hostName = hostname; # Define your hostname.
  networking.extraHosts = builtins.readFile ../dotfiles/hosts;
  networking.nameservers = [ "9.9.9.9" ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  users.mutableUsers = false;

  users.users.root.hashedPassword = secrets.root_hashed_password;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.baitinq = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" ]; # Enable ‘sudo’ for the user.
    hashedPassword = secrets.baitinq_hashed_password;
  };

  environment.variables = {
    TERMINAL = "st";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    lm_sensors
    pulseaudio # used for tools
    python
    killall
    wget
    nano
    git
    fzf
    htop
    pfetch
    unzip
    yt-dlp
    lf
    usbutils
    pciutils
    gnupg
    git-crypt
    neovim
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.listenAddresses = [{
    addr = "0.0.0.0";
    port = 2222;
  }];
  programs.ssh.askPassword = "";

  /*programs.ssh.startAgent = true;
    programs.ssh.extraConfig = ''
    AddKeysToAgent yes
    '';*/

  programs.firejail.enable = true;
  programs.firejail.wrappedBinaries = {
    discord-wrapped = {
      executable = "${lib.getBin pkgs.discord}/bin/discord";
      profile = "${pkgs.firejail}/etc/firejail/discord.profile";
    };
  };

  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "daily";
      options = "-d";
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 2222 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  #system.copySystemConfiguration = true;

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    maxJobs = "auto";
    buildCores = 0;
  };

  lib.formatter.x86_64-linux = pkgs.nixpkgs-fmt;

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}

