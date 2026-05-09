# modules/nixos/common/disko.nix — Disko module
#
# Declarative disk partitioning with Disko.
# Enable with: narbs.disko.enable = true;
# Configure with: narbs.disko.device = "/dev/nvme0n1";

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.disko;
in
{
  options.narbs.disko = {
    enable = lib.mkEnableOption "Disko declarative partitioning";
    
    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/sda";
      description = "Disk device to partition";
    };
    
    poolName = lib.mkOption {
      type = lib.types.str;
      default = "zroot";
      description = "ZFS pool name";
    };
    
    filesystem = lib.mkOption {
      type = lib.types.enum [ "zfs" "ext4" "btrfs" ];
      default = "zfs";
      description = "Root filesystem type";
    };
  };

  config = lib.mkIf cfg.enable {
    disko.devices = {
      disk = {
        main = {
          device = cfg.device;
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              
              # ZFS partition
              zfs = lib.mkIf (cfg.filesystem == "zfs") {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = cfg.poolName;
                };
              };
              
              # ext4/btrfs partition
              root = lib.mkIf (cfg.filesystem != "zfs") {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = cfg.filesystem;
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
      
      # ZFS pool configuration
      zpool = lib.mkIf (cfg.filesystem == "zfs") {
        ${cfg.poolName} = {
          type = "zpool";
          
          rootFsOptions = {
            compression = "zstd";
            acltype = "posixacl";
            xattr = "sa";
          };
          
          datasets = {
            root = {
              type = "zfs_fs";
              mountpoint = "/";
            };
            
            # Keep /home as ephemeral tmpfs with impermanence, not as ZFS dataset
            # (Impermanence handles /home as ephemeral storage)
            
            persist = {
              type = "zfs_fs";
              mountpoint = "/persist";
            };
          };
        };
      };
    };
    
    # Enable ZFS support
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.devNodes = "/dev/disk/by-path";
  };
}