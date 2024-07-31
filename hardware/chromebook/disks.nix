{ inputs, lib, config, pkgs, ... }:
let
  MMC = "/dev/disk/by-id/mmc-AGND3R_0x48d44fdc";
  SD = "/dev/disk/by-id/usb-Generic_STORAGE_DEVICE_000000000208-0:0";

  partitionsCreateScript = ''
    parted -s "${MMC}" mklabel gpt
    parted -s "${MMC}" mkpart "efi" fat32 1024KiB 64M
    parted -s "${MMC}" set 1 esp on
    parted -s -a optimal "${MMC}" mkpart  "boot" 64M 264M
    parted -s -a optimal "${MMC}" mkpart "nix" 264M 100%

    parted -s "${SD}" mklabel gpt
    parted -s -a optimal "${SD}" mkpart "home_and_persist" 1024KiB 100%

    udevadm trigger --subsystem-match=block; udevadm settle
  '';
  partitionsFormatScript = ''
    mkfs.vfat "${MMC}"-part1
    cryptsetup -q luksFormat "${MMC}"-part2  --type luks1
    cryptsetup open --type luks "${MMC}"-part2 encrypted_boot
    mkfs.ext4 /dev/mapper/encrypted_boot
    cryptsetup close encrypted_boot
    cryptsetup -q luksFormat "${MMC}"-part3  --type luks2
    cryptsetup open --type luks "${MMC}"-part3 encrypted_nix
    mkfs.btrfs -f /dev/mapper/encrypted_nix
    cryptsetup close encrypted_nix

    cryptsetup -q luksFormat "${SD}"-part1  --type luks2
    cryptsetup open --type luks "${SD}"-part1 encrypted_home_and_persist
    pvcreate /dev/mapper/encrypted_home_and_persist
    vgcreate encrypted_home_and_persist_pool /dev/mapper/encrypted_home_and_persist
    lvcreate -L 4G -n persist encrypted_home_and_persist_pool
    mkfs.btrfs -f /dev/mapper/encrypted_home_and_persist_pool-persist
    lvcreate -l 100%FREE -n home encrypted_home_and_persist_pool
    mkfs.btrfs -f /dev/mapper/encrypted_home_and_persist_pool-home
    vgchange -a n encrypted_home_and_persist_pool
    cryptsetup close encrypted_home_and_persist
  '';
  partitionsMountScript = ''
    mount -t tmpfs none /mnt
    mkdir -p /mnt/{boot,nix,persist,home}

    cryptsetup open --type luks /dev/disk/by-partlabel/boot encrypted_boot
    mount /dev/mapper/encrypted_boot /mnt/boot
    mkdir -p /mnt/boot/efi
    mount /dev/disk/by-partlabel/efi /mnt/boot/efi
    cryptsetup open --type luks /dev/disk/by-partlabel/nix encrypted_nix
    mount -o compress-force=zstd,noatime /dev/mapper/encrypted_nix /mnt/nix
    cryptsetup open --type luks /dev/disk/by-partlabel/home_and_persist encrypted_home_and_persist
    vgchange -ay encrypted_home_and_persist_pool
    mount -o compress-force=zstd /dev/mapper/encrypted_home_and_persist_pool-home /mnt/home
    mount -o compress-force=zstd,noatime /dev/mapper/encrypted_home_and_persist_pool-persist /mnt/persist
  '';

  # Utility to save a snapshot of the root tree
  save-root = pkgs.writers.writeDashBin "save-root" ''
    ${pkgs.findutils}/bin/find \
      / -xdev \( -path /tmp -o -path /var/tmp -o -path /var/log/journal \) \
      -prune -false -o -print0 | sort -z | tr '\0' '\n' > "$1"
  '';

  # Utility to compare the root tree
  diff-root = pkgs.writers.writeDashBin "diff-root" ''
    export PATH=${with pkgs; lib.makeBinPath [ diffutils less ]}:$PATH
    current="$(mktemp current-root.XXX --tmpdir)"
    trap 'rm "$current"' EXIT INT HUP
    ${save-root}/bin/save-root "$current"
    diff -u /run/initial-root "$current" --color=always | ''${PAGER:-less -R}
  '';
in
{
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
      options = [ "defaults" "mode=755" ];
    };

    boot.initrd.luks.devices."encrypted_boot" = {
      device = "/dev/disk/by-partlabel/boot";
      preLVM = true;
    };

    fileSystems."/boot" = {
      device = "/dev/mapper/encrypted_boot";
      fsType = "ext4";
    };

    fileSystems."/boot/efi" = {
      device = "/dev/disk/by-partlabel/efi";
      fsType = "vfat";
    };

    boot.initrd.luks.devices."encrypted_nix".device = "/dev/disk/by-partlabel/nix";

    fileSystems."/nix" = {
      device = "/dev/mapper/encrypted_nix";
      fsType = "btrfs";
      neededForBoot = true;
      options = [ "compress-force=zstd" "noatime" ];
    };

    boot.initrd.luks.devices."encrypted_home_and_persist".device = "/dev/disk/by-partlabel/home_and_persist";

    fileSystems."/persist" = {
      device = "/dev/mapper/encrypted_home_and_persist_pool-persist";
      fsType = "btrfs";
      neededForBoot = true;
      options = [ "compress-force=zstd" "noatime" ];
    };

    fileSystems."/home" = {
      device = "/dev/mapper/encrypted_home_and_persist_pool-home";
      fsType = "btrfs";
      options = [ "compress-force=zstd" ];
    };

    services.btrfs.autoScrub.enable = true;

    swapDevices = [ ];

    zramSwap.enable = true;


    environment.systemPackages = [
      config.disks-create
      config.disks-format
      config.disks-mount

      diff-root
    ];

    systemd.services.save-root-snapshot = {
      description = "save a snapshot of the initial root tree";
      wantedBy = [ "sysinit.target" ];
      requires = [ "-.mount" ];
      after = [ "-.mount" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      serviceConfig.ExecStart = ''${save-root}/bin/save-root /run/initial-root'';
    };
  };

  options.disks-create = with lib; mkOption rec {
    type = types.package;
    default = with pkgs; symlinkJoin {
      name = "disks-create";
      paths = [ (writeScriptBin default.name partitionsCreateScript) parted ];
    };
  };

  options.disks-format = with lib; mkOption rec {
    type = types.package;
    default = with pkgs; symlinkJoin {
      name = "disks-format";
      paths = [ (writeScriptBin default.name partitionsFormatScript) cryptsetup lvm2 dosfstools e2fsprogs btrfs-progs ];
    };
  };

  options.disks-mount = with lib; mkOption rec {
    type = types.package;
    default = with pkgs; symlinkJoin {
      name = "disks-mount";
      paths = [ (writeScriptBin default.name partitionsMountScript) cryptsetup lvm2 ];
    };
  };

}
