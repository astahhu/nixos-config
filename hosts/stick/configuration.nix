{ pkgs, ...} : {
  imports = [
     ./hardware-configuration.nix
  ];
  environment.systemPackages = [
    pkgs.btrfs-progs
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.networkmanager.enable = true;
  myprograms.cli = {
    better-tools.enable = true;
    nixvim.enable = true;
  };

  disko.devices = {
    disk = {
      main = {
        device = "/dev/null";
	type = "disk";
	content = {

	  type = "gpt";
	  partitions = {
	    MBR = {
              type = "EF02"; # for grub MBR
              size = "1M";
              priority = 1; # Needs to be first partition
            };
	    ESP = {
	      type = "EF00";
	      size = "500M";
	      content = {
	        type = "filesystem";
		format = "vfat";
		mountpoint = "/boot";
		mountOptions = [
                  "defaults"
                ];
	      };
	    };
	    root = {
              size = "100%";
	      content = {
                
	        type = "btrfs";
		extraArgs = [ "-f" ];
	      subvolumes = {
                "/root" = {
                   mountpoint = "/";
                };
                "/home" = {
                  mountpoint = "/home";
                };
                "/nix" = {
                  mountpoint = "/nix";
                };
                "/swap" = {
                  mountpoint = "/.swapvol";
                  swap.swapfile.size = "1G";
                };
              };
	      };
            };
	  };
	};
      };
    };
  };
}
