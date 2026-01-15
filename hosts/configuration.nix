{
  secrets,
  dotfiles,
  lib,
  pkgs,
  config,
  hostname,
  inputs,
  user,
  timezone,
  system,
  stateVersion,
  ...
}: {
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
    initrd.systemd.enable = true;
    loader = {
      efi = {
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
        enableCryptodisk = true;
        splashImage = null;
        useOSProber = true;
      };
      timeout = 5;
    };

    supportedFilesystems = ["ntfs"];
    tmp.useTmpfs = true;
  };

  time.timeZone = timezone;

  networking = {
    hostName = hostname;
    enableIPv6 = true;
    extraHosts = let
      hostsFile = builtins.readFile "${inputs.hosts}/hosts";
      lines = lib.splitString "\n" hostsFile;
      blacklist = [ "mixpanel.com" "mxpnl.com" ];
      filtered = builtins.filter (line:
        builtins.all (domain: !(lib.hasInfix domain line)) blacklist
      ) lines;
    in lib.concatStringsSep "\n" filtered;
    dhcpcd.enable = true;
    resolvconf.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [80 22 9090];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
    };
    wireless = {
      enable = true; # Enables wireless support via wpa_supplicant.
      networks = secrets.wifi_networks;
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true; #use same kb settings (layout) as xorg

  users.mutableUsers = false;

  users.users = {
    "root" = {
      hashedPassword = secrets.root.hashed_password;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID99gQ/AgXhgwAjs+opsRXMbWpXFRT2aqAOUbN3DsrhQ (none)"
      ];
    };

    "${user}" = {
      isNormalUser = true;
      extraGroups = ["wheel" "audio" "video"]; # Enable ‘sudo’ for the user.
      hashedPassword = secrets.baitinq.hashed_password;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID99gQ/AgXhgwAjs+opsRXMbWpXFRT2aqAOUbN3DsrhQ (none)"
      ];
      shell = pkgs.zsh;
    };
  };

  environment.variables = {
    TERMINAL = "st";
    EDITOR = "nvim";
    VISUAL = "nvim";

    XKB_DEFAULT_LAYOUT = "us";

    NIXPKGS_ALLOW_UNFREE = "1";
  };

  environment.sessionVariables = rec {
    # Use $HOME (not ${HOME}) so NixOS' pam_env generation can rewrite it to @{HOME}.
    # This matters for things started very early in PAM (e.g. gnome-keyring).
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_BIN_HOME = "$HOME/.local/bin";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_DESKTOP_DIR = "$HOME/";
  };

  environment.localBinInPath = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #(uutils-coreutils.override { prefix = ""; })
    lm_sensors
    pulseaudio # used for tools
    alsa-utils
    python3
    killall
    moreutils
    ripgrep
    gcc
    wget
    gitFull
    git-crypt
    tmux
    neovim
    htop
    pfetch
    unzip
    zip
    yt-dlp
    lf
    jq
    file
    usbutils
    pciutils
    gnupg
    xclip
    strace
    fzf
    powertop
    tpm2-tss
    inputs.deploy-rs.packages."${system}".deploy-rs
  ];

  environment.defaultPackages = [];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
    # gtk portal needed to make gtk apps happy
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  security = {
    polkit.enable = true;
    #fix swaylock
    pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
    # Auto-unlock gnome-keyring on TTY login
    pam.services.login.enableGnomeKeyring = true;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
      listenAddresses = [
        {
          addr = "0.0.0.0";
          port = 22;
        }
      ];
    };
    gnome.gnome-keyring.enable = true;
    unbound = {
      enable = true;
      settings = {
        server = {
          # Based on recommended settings in https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound
          harden-glue = true;
          harden-dnssec-stripped = true;
          use-caps-for-id = false;
          prefetch = true;
          edns-buffer-size = 1232;

          # Custom settings
          hide-identity = true;
          hide-version = true;
        };
        forward-zone = [
          # Example config with quad9
          {
            name = ".";
            forward-addr = [
                  "1.1.1.1#cloudflare-dns.com"
                  "1.0.0.1#cloudflare-dns.com"
            ];
            forward-tls-upstream = true;  # Protected DNS
          }
        ];
      };
    };
    dbus.enable = true;
    irqbalance.enable = true;
    fwupd.enable = true;
    libinput.enable = false;
    usbmuxd.enable = true;
  };

  programs = {
    zsh.enable = true;
    gnupg.agent.enable = true;

    ssh = {
      enableAskPassword = false;
    };

    light.enable = true;

    dconf.enable = true;

    command-not-found.enable = false;
    nix-index.enable = true;
    nix-index-database.comma.enable = true;

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

  # Needed for nix-* commands to use the system's nixpkgs
  environment.etc."channels/nixpkgs".source = inputs.nixpkgs.outPath;

  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = ["nixpkgs=/etc/channels/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" "/nix/var/nix/profiles/per-user/root/channels"];
    gc = {
      automatic = true;
      dates = "daily";
      options = "-d";
    };
    package = pkgs.nixVersions.stable;
    settings = {
      experimental-features = ["nix-command" "flakes" "ca-derivations" "auto-allocate-uids"];
      auto-allocate-uids = true;
      max-jobs = "auto";
      cores = 0;
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      access-tokens = "github.com=${secrets.github_access_token}";
    };
    optimise.automatic = true;

  };

  hardware.enableRedistributableFirmware = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = stateVersion; # Did you read the comment?
}
