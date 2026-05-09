# modules/nixos/common/disko-server.nix — Disko configuration for server
#
# Implements Graham Christensen's "Erase Your Darlings" pattern
# Uses ZFS snapshots to reset root to blank on every boot.

{ lib, config, hostCfg, ... }:

let
  device = hostCfg.diskDevice or "/dev/sda";
  pool = hostCfg.poolName or "zroot";
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = lib.mkDefault device;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "${pool}";
              };
            };
          };
        };
      };
    };
    zpool = {
      "${pool}" = {
        type = "zpool";
        rootFsOptions = {
          acltype = "posixacl";
          dnodesize = "auto";
          canmount = "off";
          xattr = "sa";
          relatime = "on";
          atime = "off";
          normalization = "formD";
          mountpoint = "none";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
          compression = "on";
        };
        options = {
          ashift = "12";
          autotrim = "on";
        };

        datasets = {
          local = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "false";
            };
            postCreateHook = "zfs snapshot ${pool}/local/root@blank";
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              atime = "off";
              canmount = "on";
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "false";
            };
          };
          safe = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "safe/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };
          "safe/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };
        };
      };
    };
  };

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r ${pool}/local/root@blank
  '';

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/home".neededForBoot = true;
}
