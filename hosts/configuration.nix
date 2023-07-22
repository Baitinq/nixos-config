{ secrets, dotfiles, lib, pkgs, config, hostname, inputs, user, timezone, system, stateVersion, ... }:
{

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
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
        enableCryptodisk = true;
        splashImage = null;
        useOSProber = true;
      };
      timeout = 0;
    };

    supportedFilesystems = [ "ntfs" ];
    tmp.useTmpfs = true;
  };

  time.timeZone = timezone;

  networking = {
    hostName = hostname;
    enableIPv6 = true;
    extraHosts = builtins.readFile "${inputs.hosts}/hosts";
    dhcpcd.enable = true;
    resolvconf.enable = true;
    nameservers = [ "127.0.0.1" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 22 9090 ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
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
      extraGroups = [ "wheel" "audio" "video" ]; # Enable ‘sudo’ for the user.
      hashedPassword = secrets.baitinq.hashed_password;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID99gQ/AgXhgwAjs+opsRXMbWpXFRT2aqAOUbN3DsrhQ (none)"
      ];
    };
  };

  environment.variables = {
    TERMINAL = "st";
    EDITOR = "nvim";
    VISUAL = "nvim";

    XKB_DEFAULT_LAYOUT = "gb";

    NIXPKGS_ALLOW_UNFREE = "1";
  };

  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    XDG_STATE_HOME = "\${HOME}/.local/state";
    XDG_DESKTOP_DIR = "\${HOME}/";
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
    wget
    gitFull
    git-crypt
    htop
    pfetch
    unzip
    zip
    yt-dlp
    lf
    file
    usbutils
    pciutils
    gnupg
    comma
    xclip
    strace
    inputs.deploy-rs.defaultPackage."${system}"
  ];

  environment.defaultPackages = [ ];

  environment.etc."nix-index/files".source = inputs.nix-index.legacyPackages.${system}.database;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
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
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
      listenAddresses = [{
        addr = "0.0.0.0";
        port = 22;
      }];
    };
    gnome.gnome-keyring.enable = true;
    unbound.enable = true;
    dbus.enable = true;
    irqbalance.enable = true;
    fwupd.enable = true;
    xserver.libinput.enable = false;
  };

  programs = {
    ssh = {
      enableAskPassword = false;
    };

    tmux = {
      enable = true;
      clock24 = true;
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      configure = {
        extraConfig = ''
          filetype plugin indent on
          syntax on
          set title
          set tabstop=8
          set softtabstop=8
          set shiftwidth=8
          set noexpandtab
        '';
      };
    };

    light.enable = true;

    dconf.enable = true;

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
    nixPath = [ "nixpkgs=/etc/channels/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" "/nix/var/nix/profiles/per-user/root/channels" ];
    gc = {
      automatic = true;
      dates = "daily";
      options = "-d";
    };
    package = pkgs.nixVersions.stable;
    settings = {
      experimental-features = [ "nix-command" "flakes" "ca-derivations" "auto-allocate-uids" ];
      auto-optimise-store = true;
      auto-allocate-uids = true;
      max-jobs = "auto";
      cores = 0;
    };
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

