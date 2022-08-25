{ inputs, lib, config, pkgs, ... }:
let
  partitionsConfig = {
    type = "devices";
    content = {
      "disk/by-path/platform-80860F14:00" = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            type = "partition";
            part-label = "efi";
            flags = [ "esp" ];
            start = "0";
            end = "64M";
            fs-type = "fat32";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/esp";
            };
          }
          {
            type = "partition";
            start = "64M";
            end = "264M";
            part-label = "boot";
            content = {
              type = "luks";
              name = "encrypted_boot";
              extraArgs = [ "--type luks1" ];
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
              };
            };
          }
          {
            type = "partition";
            start = "264M";
            end = "100%";
            part-label = "nix";
            content = {
              type = "luks";
              name = "encrypted_nix";
              extraArgs = [ "--type luks2" ];
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/nix";
              };
            };
          }
        ];
      };
      "disk/by-path/pci-0000:00:14.0-usb-0:2.3:1.0-scsi-0:0:0:0" = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            type = "partition";
            part-label = "home_and_persist";
            start = "0";
            end = "100%";
            content = {
              type = "luks";
              name = "encrypted_home_and_persist";
              extraArgs = [ "--type luks2" ];
              content = {
                type = "lvm";
                name = "pool";
                lvs = {
                  _persist = {
                    type = "lv";
                    size = "4G";
                    content = {
                      type = "filesystem";
                      format = "btrfs";
                      mountpoint = "/persist";
                    };
                  };
                  home = {
                    type = "lv";
                    size = "100%FREE";
                    content = {
                      type = "filesystem";
                      format = "btrfs";
                      mountpoint = "/home";
                    };
                  };
                };
              };
            };
          }
        ];
      };
    };
  };
in
{
  config = {

    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
    };

    boot.initrd.luks.devices."encrypted_boot" = {
      device = "/dev/disk/by-uuid/4f5ba100-5c69-49ce-b0cf-2f219a5e9e51";
      preLVM = true;
    };

    fileSystems."/boot" = {
      device = "/dev/mapper/encrypted_boot";
      fsType = "vfat";
    };

    fileSystems."/boot/efi" = {
      device = "/dev/disk/by-uuid/BD51-1431";
      fsType = "vfat";
    };

    boot.initrd.luks.devices."encrypted_nix".device = "/dev/disk/by-uuid/596e43d3-ccda-4f06-bce9-58d6a8c0dd79";

    fileSystems."/nix" = {
      device = "/dev/mapper/encrypted_nix";
      fsType = "btrfs";
      neededForBoot = true;
      options = [ "subvol=nix" "compress-force=zstd" "noatime" ];
    };

    boot.initrd.luks.devices."encrypted_home_and_persist".device = "/dev/disk/by-uuid/47a8ddde-1237-4a0f-84c4-f17fbd22ea3f";

    fileSystems."/persist" = {
      device = "/dev/mapper/encrypted_home_and_persist";
      fsType = "btrfs";
      neededForBoot = true;
      options = [ "subvol=persist" "compress-force=zstd" "noatime" ];
    };

    fileSystems."/home" = {
      device = "/dev/mapper/encrypted_home_and_persist";
      fsType = "btrfs";
      options = [ "subvol=home" "compress-force=zstd" ];
    };

    services.btrfs.autoScrub.enable = true;

    swapDevices = [ ];

    zramSwap.enable = true;


    environment.systemPackages = [
      config.disko-create
      config.disko-mount
    ];
  };

  options.disko-create = with lib; mkOption {
    type = types.package;
    default = pkgs.buildEnv {
      name = "disko-create";
      paths = [ (pkgs.writeScriptBin "disko-create" (inputs.disko.lib.create partitionsConfig)) pkgs.parted ];
    };
  };

  options.disko-mount = with lib; mkOption {
    type = types.package;
    default = pkgs.buildEnv {
      name = "disko-mount";
      paths = [ (pkgs.writeScriptBin "disko-mount" (inputs.disko.lib.mount partitionsConfig)) pkgs.parted ];
    };
  };

}
