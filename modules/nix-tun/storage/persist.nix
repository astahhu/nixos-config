{
  pkgs,
  config,
  lib,
  ...
}:
let
  opts = config.nix-tun.storage.persist;
in
{
  options.nix-tun.storage.persist = {
    enable = lib.mkEnableOption ''
      A wrapper around impermanence and ZFS auto snapshots.
      Expects a ZFS pool with the following dataset layout:

      - pool/root     <- mounted at /
      - pool/nix      <- mounted at /nix
      - pool/persist  <- mounted at /persist

      Each persistent entry will create its own ZFS dataset under pool/persist.
    '';

    pool = lib.mkOption {
      type = lib.types.str;
      default = "zpool";
      description = "Name of the ZFS pool used for persistent storage.";
    };

    path = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = ''
        Root directory for all non-generated persistent storage,
        except /nix and /boot.
      '';
    };

    is_server = lib.mkEnableOption ''
      Enable if this system is a server.
      Only servers are backed up automatically by the backup-server module.
    '';

    datasets = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
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
                default = "0755";
              };

              backup = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Whether this dataset should be snapshotted.";
              };

              bindMountDirectories = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = ''
                  If enabled, directories inside this dataset
                  are bind-mounted to their respective paths in /.
                '';
              };

              path = lib.mkOption {
                type = lib.types.str;
                default = "${config.nix-tun.storage.persist.path}/${name}";
              };

              directories = lib.mkOption {
                type = lib.types.attrsOf (
                  lib.types.submodule (
                    { ... }:
                    {
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
                          default = "0755";
                        };
                      };
                    }
                  )
                );
                default = { };
              };
            };
          }
        )
      );
      default = { };
      description = "ZFS datasets that should be persistent.";
    };
  };

  config = lib.mkIf opts.enable {

    ########################################
    # Default datasets
    ########################################

    nix-tun.storage.persist.datasets = {
      system = {
        directories = {
          "/var/log" = { };
          "/var/lib/nixos" = { };
          "/var/lib/systemd/coredump" = { };
          "/etc/NetworkManager/system-connections/" = lib.mkIf config.networking.networkmanager.enable {
            mode = "0700";
          };
        };
        bindMountDirectories = true;
      };

      ssh-keys = {
        backup = false;
      };
    };

    ########################################
    # ZFS dataset creation
    ########################################

    fileSystems = lib.mapAttrs' (name: value: {
      name = value.path;
      value = {
        device = "${opts.pool}/persist/${name}";
        fsType = "zfs";
      };
    }) opts.datasets;

    ########################################
    # Directory creation
    ########################################

    systemd.tmpfiles.rules = builtins.concatLists (
      lib.mapAttrsToList (
        name: value:
        [
          "d '${value.path}' ${value.mode} ${value.owner} ${value.group} -"
        ]
        ++ lib.mapAttrsToList (
          n: v: "d '${value.path}/${n}' ${v.mode} ${v.owner} ${v.group} -"
        ) value.directories
      ) opts.datasets
    );

    ########################################
    # Impermanence integration
    ########################################

    environment.persistence = lib.mapAttrs' (name: value: {
      name = value.path;
      value = {
        hideMounts = true;
        directories = lib.mapAttrsToList (n: v: {
          directory = n;
          user = v.owner;
          group = v.group;
          mode = v.mode;
        }) value.directories;
        files = [ ];
      };
    }) (lib.filterAttrs (n: v: v.bindMountDirectories) opts.datasets);

    ########################################
    # ZFS automatic snapshots
    ########################################

    services.zfs.autoSnapshot = {
      enable = true;

      frequent = 6; # hourly snapshots
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 3;

      datasets = lib.mapAttrs' (name: value: {
        name = "${opts.pool}/persist/${name}";
        value = {
          frequent = value.backup;
        };
      }) opts.datasets;
    };

    ########################################
    # SSH Host Keys (persisted)
    ########################################

    services.openssh.hostKeys = [
      {
        bits = 4096;
        openSSHFormat = true;
        path = "${opts.path}/ssh-keys/ssh_host_rsa_key";
        rounds = 100;
        type = "rsa";
      }
      {
        path = "${opts.path}/ssh-keys/ssh_host_ed25519_key";
        rounds = 100;
        type = "ed25519";
      }
    ];
  };
}
