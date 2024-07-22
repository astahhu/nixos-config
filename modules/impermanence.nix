{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.astahhu.impermanence = {
    enable = lib.mkEnableOption "Enable Impermanence - Delete Root on Every Boot";
    persistentFullHome = lib.mkEnableOption "Enable if simply all of Home should be Persistent";
    defaultPath = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "The root persistent subvolume, all other persistent files MUST be mounted beneath it";
    };

    persistentSubvolumes = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({...}: {
        options = {
          owner = lib.mkOption {
            type = lib.types.str;
            default = "root";
            description = ''
              The owner of the subvolume
            '';
          };
          group = lib.mkOption {
            type = lib.types.str;
            default = "root";
            description = ''
              The group of the subvolume
            '';
          };
          mode = lib.mkOption {
            type = lib.types.str;
            default = "0700";
            description = "The mode of the subvolume, default is 0700";
          };
          backup = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether this subvolume should be backuped, default is true";
          };
	  directories = lib.mkOption {
	    type = lib.types.attrsOf( lib.types.submodule ({...} : {
	      options = {
	      owner = lib.mkOption {
	        type = lib.types.str;
		default = "root";
	      };
	      group = lib.mkOption {
	        type = lib.types.str;
		default = "root";
	      };
	      mode = lib.mkOption {
	        type = lib.types.str;
	        default = "0700";
	      };
	      };
	    }));
	    default = {};
	    description = ''
	      Directories that should be created per default inside the subvolume
	    '';
	  };
        };
      }));
      default = "";
      description = ''
        Subvolumes that should be persistent.
      '';
    };
  };

  config = lib.mkIf config.astahhu.impermanence.enable {
    systemd.tmpfiles.rules = builtins.concatLists (lib.attrsets.mapAttrsToList (
      name: value: 
      [
	"v ${config.astahhu.impermanence.defaultPath}/${name} ${value.mode} ${value.owner} ${value.group} -"
      ] 
      ++ lib.attrsets.mapAttrsToList (n: v:
        "d ${config.astahhu.impermanence.defaultPath}/${name}/${n} ${v.mode} ${v.owner} ${v.group} -"
      ) value.directories
    )
    config.astahhu.impermanence.persistentSubvolumes);

    environment.persistence."${config.astahhu.impermanence.defaultPath}/system" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos" # For Correct User Mapping
        "/var/lib/systemd/coredump"
        # Color Profiles for Screens, Printers etc.
        {
          directory = "/var/lib/colord";
          user = "colord";
          group = "colord";
          mode = "u=rwx,g=rx,o=";
        }
        (lib.mkIf config.astahhu.impermanence.persistentFullHome "/home")
        (lib.mkIf config.networking.networkmanager.enable "/etc/NetworkManager/system-connections")
        (lib.mkIf config.services.printing.enable "/var/lib/cups")
      ];
      files = [
      ];
    };

    services.openssh.hostKeys = [
      {
        bits = 4096;
        openSSHFormat = true;
        path = "${config.astahhu.impermanence.defaultPath}/system/etc/ssh/ssh_host_rsa_key";
        rounds = 100;
        type = "rsa";
      }
      {
        comment = "key comment";
        path = "${config.astahhu.impermanence.defaultPath}/system/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        type = "ed25519";
      }
    ];
  };
}
