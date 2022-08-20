## DESCRIPTION ##

## mount /dev/sdX1 /mnt/boot## sd as home and persist (4 and 60GB) (encrypted) (in btrfs subvols)

## root as nix and (encrypted) and boot (150M)

## tmpfs as root


## TUTORIAL ## 

# Create and Format 64M EFI Partition
mkfs.fat -F 32 /dev/$EFIPARTITION

# Create and Encrypt 200M /boot Partition
cryptsetup --verify-passphrase -v luksFormat --type luks1 /dev/$BOOTPARTITION
cryptsetup open /dev/$BOOTPARTITION encrypted_boot
mkfs.fat -F 32 /dev/mapper/encrypted_boot


# Create and Encrypt /nix Partition
cryptsetup --verify-passphrase -v luksFormat /dev/$NIXPARTITION
cryptsetup open /dev/$NIXPARTITION encrypted_nix
mkfs.btrfs /dev/mapper/encrypted_nix

# Format /nix Partition
mount -t btrfs /dev/mapper/encrypted_nix /mnt
btrfs subvolume create /mnt/nix
umount /mnt


# Create and Encrypt /home and /persist Partitions
cryptsetup --verify-passphrase -v luksFormat /dev/$HOME_AND_PERSIST_PARTITION
cryptsetup open /dev/$NIXPARTITION encrypted_home_and_persist
mkfs.btrfs /dev/mapper/encrypted_home_and_persist

# Format /home and /persist Partitions
mount -t btrfs /dev/mapper/encrypted_home_and_persist /mnt
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/persist
umount /mnt

# Mount tmpfs in /
mount -t tmpfs none /mnt
mkdir -p /mnt/{boot,nix,persist,home}

# Mount all partitions in /
mount /dev/mapper/encrypted_boot /mnt/boot
mount /dev/$EFIPARTITION /mnt/boot/efi
mount -o subvol=nix,compress-force=zstd,noatime /dev/mapper/encrypted_nix /mnt/nix
mount -o subvol=home,compress-force=zstd /dev/mapper/encrypted_home_and_persist /mnt/home
mount -o subvol=persist,compress-force=zstd,noatime /dev/mapper/encrypted_home_and_persist /mnt/persist

# Install nixos
nixos-install --flake .#HOST
