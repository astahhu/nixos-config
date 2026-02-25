{
  config,
  pkgs,
  lib,
  ...
}:

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

  config = lib.mkIf config.astahhu.services.samba.fs.enable (
    let
      cfg = config.astahhu.services.samba;
    in
    {

      ########################################
      # Required Services
      ########################################

      astahhu.services.samba.enable = true;

      services.samba = {
        enable = true;
        package = cfg.package;
        openFirewall = true;
        nmbd.enable = false;
        nsswins = false;

        settings = {

          global = {
            security = "ads";
            "allow trusted domains" = "yes";
            "server services" = "-nbt";

            "winbind refresh tickets" = true;
            "winbind offline logon" = true;

            "template shell" = "${pkgs.fish}/bin/fish";

            "idmap config * : range" = "100000 - 199999";
            "idmap config AD : backend" = "rid";
            "idmap config AD : range" = "1000000 - 1999999";

            "inherit acls" = "yes";
            "vfs objects" = "acl_xattr";
          };

        }
        // (lib.mapAttrs (
          name: value:
          let
            sharePath = config.nix-tun.storage.persist.datasets."samba-shares/${name}".path;

            dataset = "${config.nix-tun.storage.persist.pool}/persist/samba-shares/${name}";
          in
          {
            path = sharePath;
            { config
, pkgs
, lib
, ...
}:

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

  config = lib.mkIf config.astahhu.services.samba.fs.enable
    (let
      cfg = config.astahhu.services.samba;
    in
    {

      ########################################
      # Required Services
      ########################################

      astahhu.services.samba.enable = true;

      services.samba = {
        enable = true;
        package = cfg.package;
        openFirewall = true;
        nmbd.enable = false;
        nsswins = false;

        settings = {

          global = {
            security = "ads";
            "allow trusted domains" = "yes";
            "server services" = "-nbt";

            "winbind refresh tickets" = true;
            "winbind offline logon" = true;

            "template shell" = "${pkgs.fish}/bin/fish";

            "idmap config * : range" = "100000 - 199999";
            "idmap config AD : backend" = "rid";
            "idmap config AD : range" = "1000000 - 1999999";

            "inherit acls" = "yes";
            "vfs objects" = "acl_xattr";
          };

        }
        // (lib.mapAttrs
          (name: value:
            let
              sharePath =
                config.nix-tun.storage.persist.datasets."samba-shares/${name}".path;

              dataset =
                "${config.nix-tun.storage.persist.pool}/persist/samba-shares/${name}";
            in
            {
              path = sharePath;
              "read only" = "no";
              "administrative share" = "yes";

              ####################################
              # ZFS Shadow Copies
              ####################################

              "vfs objects" = "shadow_copy_zfs acl_xattr";
              "shadow:dataset" = dataset;
              "shadow:format" = "auto-%Y-%m-%d-%H%M";
              "shadow:sort" = "desc";

              "inherit permissions" = "yes";
              "inherit owner" = "yes";
            }
            // value
          )
          cfg.shares);
      };

      ########################################
      # NSS / Winbind
      ########################################

      system.nssDatabases.passwd = [ "winbind" ];
      system.nssDatabases.group = [ "winbind" ];

      services.nscd.enable = false;
      system.nssModules = lib.mkForce [ ];

      security.pam.services.samba.text = ''
        account required ${cfg.package}/lib/security/pam_winbind.so
        auth required ${cfg.package}/lib/security/pam_winbind.so
        password required ${cfg.package}/lib/security/pam_winbind.so
        session required ${cfg.package}/lib/security/pam_winbind.so
      '';

      security.pam.krb5.enable = false;

      ########################################
      # Firewall
      ########################################

      networking.firewall.allowedTCPPorts = [ 135 139 445 ];
      networking.firewall.allowedUDPPorts = [ 137 138 ];
      networking.firewall.allowedTCPPortRanges = [
        { from = 49152; to = 65535; }
      ];

      ########################################
      # Persistent Storage (ZFS)
      ########################################

      nix-tun.storage.persist.datasets =
        lib.mapAttrs'
          (name: _: {
            name = "samba-shares/${name}";
            value = {
              backup = true;
              path =
                "${config.nix-tun.storage.persist.path}/samba-shares/${name}";
              mode = "0770";
              group = "1000512";
            };
          })
          cfg.shares
        // {
          samba = {
            bindMountDirectories = true;
            directories = {
              "/var/lib/samba" = { };
              "/var/lib/samba/private" = { };
              "/var/lock/samba" = { };
            };
          };
        };
    });
{ config
, pkgs
, lib
, ...
}:

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

  config = lib.mkIf config.astahhu.services.samba.fs.enable
    (let
      cfg = config.astahhu.services.samba;
    in
    {

      ########################################
      # Required Services
      ########################################

      astahhu.services.samba.enable = true;

      services.samba = {
        enable = true;
        package = cfg.package;
        openFirewall = true;
        nmbd.enable = false;
        nsswins = false;

        settings = {

          global = {
            security = "ads";
            "allow trusted domains" = "yes";
            "server services" = "-nbt";

            "winbind refresh tickets" = true;
            "winbind offline logon" = true;

            "template shell" = "${pkgs.fish}/bin/fish";

            "idmap config * : range" = "100000 - 199999";
            "idmap config AD : backend" = "rid";
            "idmap config AD : range" = "1000000 - 1999999";

            "inherit acls" = "yes";
            "vfs objects" = "acl_xattr";
          };

        }
        // (lib.mapAttrs
          (name: value:
            let
              sharePath =
                config.nix-tun.storage.persist.datasets."samba-shares/${name}".path;

              dataset =
                "${config.nix-tun.storage.persist.pool}/persist/samba-shares/${name}";
            in
            {
              path = sharePath;
              "read only" = "no";
              "administrative share" = "yes";

              ####################################
              # ZFS Shadow Copies
              ####################################

              "vfs objects" = "shadow_copy_zfs acl_xattr";
              "shadow:dataset" = dataset;
              "shadow:format" = "auto-%Y-%m-%d-%H%M";
              "shadow:sort" = "desc";

              "inherit permissions" = "yes";
              "inherit owner" = "yes";
            }
            // value
          )
          cfg.shares);
      };

      ########################################
      # NSS / Winbind
      ########################################

      system.nssDatabases.passwd = [ "winbind" ];
      system.nssDatabases.group = [ "winbind" ];

      services.nscd.enable = false;
      system.nssModules = lib.mkForce [ ];

      security.pam.services.samba.text = ''
        account required ${cfg.package}/lib/security/pam_winbind.so
        auth required ${cfg.package}/lib/security/pam_winbind.so
        password required ${cfg.package}/lib/security/pam_winbind.so
        session required ${cfg.package}/lib/security/pam_winbind.so
      '';

      security.pam.krb5.enable = false;

      ########################################
      # Firewall
      ########################################

      networking.firewall.allowedTCPPorts = [ 135 139 445 ];
      networking.firewall.allowedUDPPorts = [ 137 138 ];
      networking.firewall.allowedTCPPortRanges = [
        { from = 49152; to = 65535; }
      ];

      ########################################
      # Persistent Storage (ZFS)
      ########################################

      nix-tun.storage.persist.datasets =
        lib.mapAttrs'
          (name: _: {
            name = "samba-shares/${name}";
            value = {
              backup = true;
              path =
                "${config.nix-tun.storage.persist.path}/samba-shares/${name}";
              mode = "0770";
              group = "1000512";
            };
          })
          cfg.shares
        // {
          samba = {
            bindMountDirectories = true;
            directories = {
              "/var/lib/samba" = { };
              "/var/lib/samba/private" = { };
              "/var/lock/samba" = { };
            };
          };
        };
    });
}
