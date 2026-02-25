{ config
, pkgs
, lib
, ...
}: {
  options.nix-tun.storage.backup = {
    enable = lib.mkEnableOption "Enable Backup System";
    nixosConfigs = lib.mkOption {
      type = lib.types.unspecified;
      default = { };
      description = ''
        The list of nixos configurations from the systems to backups. Evaluates the nix-tun.storage.persist.profile for backups
      '';
    };
    server = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ ... }: {
        options = {
          host = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = ''
              The hostName or ip address of the server, if null uses the name
            '';
          };
          btrfs_base = lib.mkOption {
            type = lib.types.str;
            default = "/";
            description = ''
              The base btrfs mount point on the server.
            '';
          };
          subvolumes = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = ''
              The subvolumes on server to backup
            '';
          };
        };
      }));
    };
  };

  config = lib.mkIf config.nix-tun.storage.backup.enable {
    nix-tun.storage.backup.server =
      lib.attrsets.mapAttrs
        (name: value: {
          host = value.options.networking.hostName.value;
          btrfs_base = value.options.nix-tun.storage.persist.path.value;
          subvolumes = lib.attrsets.mapAttrsToList
            (
              name: value:
                name
            )
            (lib.attrsets.filterAttrs (n: v: v.backup) value.options.nix-tun.storage.persist.subvolumes.value);
        })
        (lib.attrsets.filterAttrs (n: v: v.options.nix-tun.storage.persist.is_server.value) config.nix-tun.storage.backup.nixosConfigs);

    systemd.tmpfiles.rules = builtins.concatLists (lib.attrsets.mapAttrsToList
      (name: value:
        [
          "v '/backup/${name}${value.btrfs_base}' 0700 btrbk btrbk"
        ]
        ++ (lib.lists.map
          (
            v: "d '/backup/${name}${value.btrfs_base}/${v}' 0700 btrbk btrbk"
          )
          value.subvolumes))
      config.nix-tun.storage.backup.server);

    services.btrbk.instances =
      lib.attrsets.mapAttrs
        (name: value: {
          settings = {
            backend_remote = "btrfs-progs-sudo";
            snapshot_preserve = "6h 7d";
            target_preserve = "14d 4w 6m";
            ssh_identity = "/etc/btrbk/id_ed25519";
            ssh_user = "btrbk";
            volume = {
              "ssh://${value.host}${value.btrfs_base}" = {
                subvolume = builtins.listToAttrs (builtins.map
                  (n: {
                    name = n;
                    value = {
                      snapshot_create = "always";
                      snapshot_dir = "${n}/.snapshots";
                      target = "/backup/${name}${value.btrfs_base}/${n}";
                    };
                  })
                  value.subvolumes);
              };
            };
          };
        })
        config.nix-tun.storage.backup.server;
  };
}
