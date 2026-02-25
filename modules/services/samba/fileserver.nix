{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.astahhu.services.samba;
in
{
  options.astahhu.services.samba.fs = {
    enable = lib.mkEnableOption "Enable Samba Fileserver";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.samba;
    };

    shares = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Samba Shares";
    };
  };

  config = lib.mkIf config.astahhu.services.samba.fs.enable {

    ########################################
    # Samba Service
    ########################################

    services.samba = {
      enable = true;
      package = cfg.package;
      openFirewall = true;
      nmbd.enable = false;
      nsswins = false;

      settings = lib.mkMerge [

        # Global settings
        {
          global = {
            security = "ads";
            "server services" = "-nbt";
            "inherit acls" = "yes";
            "vfs objects" = "acl_xattr";
          };
        }

        # Per-share settings
        (lib.mapAttrs (
          name: value:
          let
            sharePath = config.nix-tun.storage.persist.datasets."samba-shares/${name}".path;
            dataset = "${config.nix-tun.storage.persist.pool}/persist/samba-shares/${name}";
          in
          {
            ${name} = {
              path = sharePath;
              "read only" = "no";

              "vfs objects" = "shadow_copy_zfs acl_xattr";
              "shadow:dataset" = dataset;
              "shadow:format" = "auto-%Y-%m-%d-%H%M";
              "shadow:sort" = "desc";

              "inherit permissions" = "yes";
              "inherit owner" = "yes";
            }
            // value;
          }
        ) cfg.shares)
      ];
    };

    ########################################
    # ZFS Datasets for Shares
    ########################################

    nix-tun.storage.persist.datasets = lib.mapAttrs' (name: _: {
      name = "samba-shares/${name}";
      value = {
        backup = true;
        path = "${config.nix-tun.storage.persist.path}/samba-shares/${name}";
        mode = "0770";
        group = "1000512";
      };
    }) cfg.shares;

    ########################################
    # Firewall
    ########################################

    networking.firewall.allowedTCPPorts = [
      135
      139
      445
    ];
    networking.firewall.allowedUDPPorts = [
      137
      138
    ];
  };
}
