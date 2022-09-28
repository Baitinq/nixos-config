{ secrets, dotfiles, lib, pkgs, config, hostname, inputs, user, timezone, system, ... }: {

  imports = [
    "${inputs.impermanence}/nixos.nix"

    ../modules/doas
    ../modules/pipewire
    ../modules/xorg
    ../modules/fonts
    ../modules/virtualisation

    ../secrets/wireguard
  ];

  boot = lib.mkForce {
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

    supportedFilesystems = [ "ntfs" ];
    cleanTmpDir = true;
  };

  # Set your time zone.
  time.timeZone = timezone;

  networking = {
    hostName = hostname; # Define your hostname.
    extraHosts = builtins.readFile "${dotfiles}/hosts";
    nameservers = [ "9.9.9.9" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 22 ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true; #use same kb settings (layout) as xorg

  users.mutableUsers = false;

  users.users.root.hashedPassword = secrets.root.hashed_password;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" ]; # Enable ‘sudo’ for the user.
    hashedPassword = secrets.baitinq.hashed_password;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID99gQ/AgXhgwAjs+opsRXMbWpXFRT2aqAOUbN3DsrhQ (none)"
    ];
  };

  environment.variables = {
    TERMINAL = "st";
    EDITOR = "nvim";
    VISUAL = "nvim";

    XKB_DEFAULT_LAYOUT = "gb";
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
    gitFull
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
    strace
  ];

  environment.defaultPackages = [ ];

  environment.etc."nix-index/files".source = inputs.nix-index.legacyPackages.${system}.database;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  #fix swaylock
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
      listenAddresses = [{
        addr = "0.0.0.0";
        port = 22;
      }];
    };
    dbus.enable = true;
    irqbalance.enable = true;
    fwupd.enable = true;
  };

  programs = {
    ssh = {
      enableAskPassword = false;
      forwardX11 = true;
    };

    tmux = {
      enable = true;
      clock24 = true;
    };

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

  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    gc = {
      automatic = true;
      dates = "daily";
      options = "-d";
    };
    package = pkgs.nixVersions.stable;
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

