{
  device ? throw "Set this to your disk device, e.g. /dev/sda",
  ...
}:
{
  disko.devices = {
    disk.main = {
      inherit device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
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
            size = "8G";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "root_vg";
            };
          };
        };
      };
    };
    lvm_vg = {
      root_vg = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];

              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                };

                #"/persist" = {
                #  mountpoint = "/persist";
                #  mountOptions = ["noatime"];
                #};

                "/nix" = {
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
      };
    };
  };
}
