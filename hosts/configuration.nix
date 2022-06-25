{ secrets, lib, pkgs, config, hostname, inputs, user, ... }: {

  imports = [
    ../modules/doas
    ../modules/pipewire
    ../modules/xorg
    ../modules/fonts
    ../modules/virtualisation
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
      };
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
      timeout = 0;
    };

    cleanTmpDir = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  networking = {
    hostName = hostname; # Define your hostname.
    extraHosts = builtins.readFile ../dotfiles/hosts;
    nameservers = [ "9.9.9.9" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 2222 ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
    };
    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    useDHCP = lib.mkDefault true;
    # interfaces.enp0s3.useDHCP = lib.mkDefault true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true; #use same kb settings (layout) as xorg

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
    zip
    yt-dlp
    lf
    usbutils
    pciutils
    gnupg
    neovim
    steam-run
    compsize #used to check btrfs space savings
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # List services that you want to enable:
  services = {
    openssh = {
      enable = true;
      listenAddresses = [{
        addr = "0.0.0.0";
        port = 2222;
      }];
    };
  };

  programs = {
    ssh.askPassword = "";

    firejail = {
      enable = true;
      wrappedBinaries = {
        discord-wrapped = {
          executable = "${lib.getBin pkgs.discord}/bin/discord";
          profile = "${pkgs.firejail}/etc/firejail/discord.profile";
        };
      };
    };
  };

  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "daily";
      options = "-d";
    };
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    maxJobs = "auto";
    buildCores = 0;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  #system.copySystemConfiguration = true;

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}

