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
      ZFS-based persistence layer.

      Expected layout:

        pool/root     → /
        pool/nix      → /nix
        pool/persist  → /persist

      Each entry creates a ZFS dataset under:
        <pool>/persist/<name>
    '';

    pool = lib.mkOption {
      type = lib.types.str;
      default = "zpool";
      description = "Name of the ZFS pool.";
    };

    path = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "Root persistence mountpoint.";
    };

    is_server = lib.mkEnableOption "Mark this system as a server.";

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
                description = "Enable ZFS snapshotting for this dataset.";
              };

              bindMountDirectories = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Enable impermanence bind mounts.";
              };

              path = lib.mkOption {
                type = lib.types.str;
                default = "${opts.path}/${name}";
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
    };
  };

  config = lib.mkIf opts.enable {

    ########################################
    # Default datasets
    ########################################

    nix-tun.storage.persist.datasets = {

      system = {
        bindMountDirectories = true;

        directories = {
          "/var/log" = { };
          "/var/lib/nixos" = { };
          "/var/lib/systemd/coredump" = { };

          "/etc/NetworkManager/system-connections/" = lib.mkIf config.networking.networkmanager.enable {
            mode = "0700";
          };
        };
      };

      ssh-keys = {
        backup = false;
      };
    };

    ########################################
    # ZFS Filesystem Mounts
    ########################################

    fileSystems = lib.mapAttrs' (name: value: {
      name = value.path;
      value = {
        device = "${opts.pool}/persist/${name}";
        fsType = "zfs";
      };
    }) opts.datasets;

    ########################################
    # Directory Creation
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
    # Impermanence Integration
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
    }) (lib.filterAttrs (_: v: v.bindMountDirectories) opts.datasets);

    ########################################
    # ZFS Auto Snapshot (GLOBAL)
    ########################################

    services.zfs.autoSnapshot = {
      enable = true;

      frequent = 6;
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 3;
    };

    ########################################
    # SSH Host Keys
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
