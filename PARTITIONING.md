# mkfs.fat -F 32 /dev/sdX1

# mkfs.btrfs /dev/sdX2
# mkdir -p /mnt
# mount /dev/sdX2 /mnt
# btrfs subvolume create /mnt/root
# btrfs subvolume create /mnt/home
# btrfs subvolume create /mnt/nix
# umount /mnt

# mount -o compress=zstd,noatime,subvol=root /dev/sdX2 /mnt
# mkdir /mnt/{home,nix}
# mount -o compress=zstd,subvol=home /dev/sdX2 /mnt/home
# mount -o compress=zstd,noatime,subvol=nix /dev/sdX2 /mnt/nix

# mkdir /mnt/boot
# mount /dev/sdX1 /mnt/boot