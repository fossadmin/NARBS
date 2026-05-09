# disko.nix - Declarative ZFS disk partitioning for NARBS server
#
# Creates a single-disk ZFS setup with:
# - EFI System Partition (512MB)
# - ZFS pool with root, home, and persist datasets

{
  disko.devices = {
    disk = {
      main = {
        # Change this to your actual device (e.g., /dev/nvme0n1)
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            
            # ZFS partition (remaining space)
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    
    # ZFS pool configuration
    zpool = {
      zroot = {
        type = "zpool";
        
        # ZFS options for compression and features
        rootFsOptions = {
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          "com.sun:auto-snapshot" = "true";
        };
        
        datasets = {
          # Root filesystem
          root = {
            type = "zfs_fs";
            mountpoint = "/";
          };
          
          # Home directory dataset
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
          };
          
          # Persistent data (for services like Homepage, Uptime Kuma)
          persist = {
            type = "zfs_fs";
            mountpoint = "/persist";
          };
        };
      };
    };
  };
}