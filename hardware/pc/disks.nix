{
  config,
  lib,
  inputs,
  pkgs,
  modulesPath,
  isIso,
  ...
}: let
  HDD = "/dev/disk/by-id/nvme-WD_BLACK_SN770_1TB_2251AD458811";

  partitionsCreateScript = ''
    parted -s "${HDD}" mklabel gpt
    parted -s "${HDD}" mkpart "efi" fat32 1024KiB 64M
    parted -s "${HDD}" set 1 esp on
    parted -s -a optimal "${HDD}" mkpart  "boot" 64M 264M
    parted -s -a optimal "${HDD}" mkpart "root" 264M 100%

    udevadm trigger --subsystem-match=block; udevadm settle
  '';
  partitionsFormatScript = ''
    mkfs.vfat "${HDD}"-part1
    mkfs.ext4 "${HDD}"-part2
    cryptsetup -q luksFormat "${HDD}"-part3  --type luks2
    systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0 "${HDD}"-part3
    cryptsetup open --type luks "${HDD}"-part3 encrypted_root
    pvcreate /dev/mapper/encrypted_root
    vgcreate encrypted_root_pool /dev/mapper/encrypted_root
    lvcreate -L 4G -n persist encrypted_root_pool
    mkfs.btrfs -f /dev/mapper/encrypted_root_pool-persist
    lvcreate -L 128G -n nix encrypted_root_pool
    mkfs.btrfs -f /dev/mapper/encrypted_root_pool-nix
    lvcreate -l 100%FREE -n home encrypted_root_pool
    mkfs.btrfs -f /dev/mapper/encrypted_root_pool-home
    vgchange -a n encrypted_root_pool
    cryptsetup close encrypted_root
  '';
  partitionsMountScript = ''
    mount -t tmpfs none /mnt
    mkdir -p /mnt/{boot,nix,persist,home}

    mount /dev/disk/by-partlabel/boot /mnt/boot
    mkdir -p /mnt/boot/efi
    mount /dev/disk/by-partlabel/efi /mnt/boot/efi
    cryptsetup open --type luks /dev/disk/by-partlabel/root encrypted_root
    vgchange -ay encrypted_root_pool
    mount -o compress-force=zstd /dev/mapper/encrypted_root_pool-home /mnt/home
    mount -o compress-force=zstd,noatime /dev/mapper/encrypted_root_pool-persist /mnt/persist
    mount -o compress-force=zstd,noatime /dev/mapper/encrypted_root_pool-nix /mnt/nix
  '';

  # Utility to save a snapshot of the root tree
  save-root = pkgs.writers.writeDashBin "save-root" ''
    ${pkgs.findutils}/bin/find \
      / -xdev \( -path /tmp -o -path /var/tmp -o -path /var/log/journal \) \
      -prune -false -o -print0 | sort -z | tr '\0' '\n' > "$1"
  '';

  # Utility to compare the root tree
  diff-root = pkgs.writers.writeDashBin "diff-root" ''
    export PATH=${with pkgs; lib.makeBinPath [diffutils less]}:$PATH
    current="$(mktemp current-root.XXX --tmpdir)"
    trap 'rm "$current"' EXIT INT HUP
    ${save-root}/bin/save-root "$current"
    diff -u /run/initial-root "$current" --color=always | ''${PAGER:-less -R}
  '';
in {
  config = {
    environment.persistence."/persist" = {
      directories = [
        "/var/log"
        "/var/lib"
        "/root"
      ];
      files = [
        "/etc/machine-id"
        "/etc/nix/id_rsa"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
    };

    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "mode=755"];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "ext4";
    };

    fileSystems."/boot/efi" = {
      device = "/dev/disk/by-partlabel/efi";
      fsType = "vfat";
    };

    boot.initrd.luks.devices."encrypted_root".device = "/dev/disk/by-partlabel/root";

    fileSystems."/nix" = {
      device = "/dev/mapper/encrypted_root_pool-nix";
      fsType = "btrfs";
      neededForBoot = true;
      options = ["compress-force=zstd" "noatime"];
    };

    fileSystems."/persist" = {
      device = "/dev/mapper/encrypted_root_pool-persist";
      fsType = "btrfs";
      neededForBoot = true;
      options = ["compress-force=zstd" "noatime"];
    };

    fileSystems."/home" = {
      device = "/dev/mapper/encrypted_root_pool-home";
      fsType = "btrfs";
      options = ["compress-force=zstd"];
    };

    swapDevices = [];

    services.btrfs.autoScrub.enable = true;

    zramSwap.enable = true;

    environment.systemPackages = [
      config.disks-create
      config.disks-format
      config.disks-mount

      diff-root
    ];

    systemd.services.save-root-snapshot = {
      description = "save a snapshot of the initial root tree";
      wantedBy = ["sysinit.target"];
      requires = ["-.mount"];
      after = ["-.mount"];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      serviceConfig.ExecStart = ''${save-root}/bin/save-root /run/initial-root'';
    };
  };

  options.disks-create = with lib;
    mkOption rec {
      type = types.package;
      default = with pkgs;
        symlinkJoin {
          name = "disks-create";
          paths = [(writeShellScriptBin default.name partitionsCreateScript) parted];
        };
    };

  options.disks-format = with lib;
    mkOption rec {
      type = types.package;
      default = with pkgs;
        symlinkJoin {
          name = "disks-format";
          paths = [(writeShellScriptBin default.name partitionsFormatScript) cryptsetup lvm2 dosfstools e2fsprogs btrfs-progs];
        };
    };

  options.disks-mount = with lib;
    mkOption rec {
      type = types.package;
      default = with pkgs;
        symlinkJoin {
          name = "disks-mount";
          paths = [(writeShellScriptBin default.name partitionsMountScript) cryptsetup lvm2];
        };
    };
}
