{ secrets, lib, pkgs, config, hostname, inputs, user, timezone, ... }: {

  imports = [
    "${inputs.impermanence}/nixos.nix"

    ../modules/doas
    ../modules/pipewire
    ../modules/xorg
    ../modules/fonts
    ../modules/virtualisation

    ../secrets/wireguard
  ];

  boot = {
    loader = {
      efi = {
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        enable = true;
        version = 2;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
        enableCryptodisk = true;
        splashImage = null;
      };
      timeout = 0;
    };

    cleanTmpDir = true;
  };

  # Set your time zone.
  time.timeZone = timezone;

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
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true; #use same kb settings (layout) as xorg

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  users.mutableUsers = false;

  users.users.root.hashedPassword = secrets.root.hashed_password;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.baitinq = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" ]; # Enable ‘sudo’ for the user.
    hashedPassword = secrets.baitinq.hashed_password;
  };

  environment.variables = {
    TERMINAL = "st";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    XDG_STATE_HOME = "\${HOME}/.local/state";

    PATH = [
      "\${XDG_BIN_HOME}"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (uutils-coreutils.override { prefix = ""; })
    lm_sensors
    pulseaudio # used for tools
    python
    killall
    wget
    git
    git-crypt
    htop
    pfetch
    unzip
    zip
    yt-dlp
    lf
    usbutils
    pciutils
    gnupg
    comma
    xclip
  ];

  environment.defaultPackages = [ ];

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

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    light.enable = true;

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

  environment.persistence."/persist" = {
    directories = [
      "/var/log"
      "/var/lib"
    ];
    files = [
      "/etc/machine-id"
      "/etc/nix/id_rsa"
    ];
  };

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "-d";
    };
    package = pkgs.nixFlakes;
    settings = {
      experimental-features = [ "nix-command" "flakes" "ca-derivations" ];
      auto-optimise-store = true;
      max-jobs = "auto";
      cores = 0;
    };
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

