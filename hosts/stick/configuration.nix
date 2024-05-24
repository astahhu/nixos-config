{ pkgs, ...} : {
  environment.systemPackages = [
    pkgs.btrfs-progs
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;
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
	      type = "EF02";
	      size = "1M";
	      priority = 1;
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
	    luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted2";
		extraOpenArgs = [ "--allow-discards" ];
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
                      swap.swapfile.size = "20M";
                    };
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
