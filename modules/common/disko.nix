{
  device ? throw "Set this to your disk device, e.g. /dev/sda",
  swap ? "8G",
  poolName ? "zpool",
  ...
}:

{
  disko.devices = {

    ########################################
    # Physical Disk
    ########################################

    disk.main = {
      inherit device;
      type = "disk";
      imageSize = "30G";

      content = {
        type = "gpt";

        partitions = {

          boot = {
            name = "boot";
            size = "1M";
            type = "EF02"; # BIOS boot (optional if UEFI only)
          };

          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };

          swap = {
            size = swap;
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };

          zfs = {
            name = "zfs";
            size = "100%";
            content = {
              type = "zfs";
              pool = poolName;
            };
          };
        };
      };
    };

    ########################################
    # ZFS Pool + Datasets
    ########################################

    zpool.${poolName} = {
      type = "zpool";

      options = {
        ashift = "12";
        autotrim = "on";
      };

      rootFsOptions = {
        compression = "zstd";
        atime = "off";
        xattr = "sa";
        acltype = "posixacl";
        mountpoint = "none";
      };

      datasets = {

        ####################################
        # Root Dataset
        ####################################

        "root" = {
          type = "zfs_fs";
          mountpoint = "/";
          options = {
            mountpoint = "legacy";
          };
        };

        ####################################
        # Nix Dataset
        ####################################

        "nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options = {
            mountpoint = "legacy";
          };
        };

        ####################################
        # Persist Dataset
        ####################################

        "persist" = {
          type = "zfs_fs";
          mountpoint = "/persist";
          options = {
            mountpoint = "legacy";
          };
        };
      };
    };
  };
}
