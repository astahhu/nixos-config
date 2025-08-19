{ config
, pkgs
, lib
, ...
}: {
  options = {
    astahhu.services.samba.fs = {
      enable = lib.mkEnableOption "Enable Samba Fileserver";
      shares = lib.mkOption {
        type = lib.types.attrs;
        description = "Samba Shares";
        default = { };
      };
    };
  };

  config = lib.mkIf config.astahhu.services.samba.fs.enable (
    let cfg = config.astahhu.services.samba;
    in {
      system.nssDatabases.passwd = [ "winbind" ];
      system.nssDatabases.group = [ "winbind" ];
      astahhu.services.samba.enable = true;
      fileSystems =
        lib.attrsets.mapAttrs'
          (name: value: {
            name = "/persist/samba-shares/${name}";
            value = {
              device = "/dev/root_vg/root";
              options = [ "noauto" "subvol=/persist/samba-shares/${name}" ];
              depends = [ "/persist" ];
              fsType = "btrfs";
            };
          })
          cfg.fs.shares;

      nix-tun.storage.persist.subvolumes =
        lib.attrsets.mapAttrs'
          (name: value: {
            name = "samba-shares/${name}";
            value.group = "1000512";
            value.mode = "0770";
          })
          cfg.fs.shares
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

      systemd.services.samba-smbd.preStart = lib.strings.concatStrings (lib.attrsets.mapAttrsToList (name: _: "${pkgs.mount}/bin/mount \"${config.nix-tun.storage.persist.path}/samba-shares/${name}\"\n") cfg.fs.shares);
      systemd.services.samba-smbd.postStop = lib.strings.concatStrings (lib.attrsets.mapAttrsToList (name: _: "${pkgs.mount}/bin/umount \"${config.nix-tun.storage.persist.path}/samba-shares/${name}\"\n") cfg.fs.shares);
      services.nscd.enable = false;
      system.nssModules = lib.mkForce [ ];
      security.pam.services.samba.text = ''
        account required ${cfg.package}/lib/security/pam_winbind.so
      
        auth required ${cfg.package}/lib/security/pam_winbind.so
      
        password required ${cfg.package}/lib/security/pam_winbind.so
      
        session required ${cfg.package}/lib/security/pam_winbind.so
      '';

      environment.etc."security/pam_winbind.conf".text = ''
        [global]
        krb5_auth = yes
        krb5_ccache_type = FILE
      '';

      security.pam.krb5.enable = false;
      security.krb5 = {
        enable = true;
        package = pkgs.heimdal;
        settings = {
          libdefaults = {
            default_realm = "AD.ASTAHHU.DE";
            dns_lookup_realm = false;
            dns_lookup_kdc = true;
          };
          realms = {
            "AD.ASTAHHU.DE" = {
              "default_domain" = "ad.astahhu.de";
            };
          };
        };
      };

      networking.firewall.allowedTCPPorts = [
        445
      ];
      networking.firewall.allowedTCPPortRanges = [
        { from = 49152; to = 65535; }
      ];

      services.samba = {
        enable = true;
        package = cfg.package;
        openFirewall = true;
        nsswins = true;
        nmbd.enable = false;


        settings =
          {
            global =
              {
                "allow trusted domains" = "yes";
                "security" = "ads";
                "log level" = "0";
                "guest ok" = false;
                "winbind refresh tickets" = true;
                "restrict anonymous" = 0;
                "template shell" = "${pkgs.fish}/bin/fish";
                "idmap config * : range" = "100000 - 199999";
                "idmap config AD.ASTAHHU : backend" = "rid";
                "idmap config AD.ASTAHHU : range" = "1000000 - 1999999";
                "idmap config ASTA2012 : backend" = "rid";
                "idmap config ASTA2012 : range" = "2000000 - 2999999";
                "inherit acls" = "yes";
                "vfs objects" = "acl_xattr";
              };
          } //
          (lib.attrsets.mapAttrs'
            (name: value: {
              name = "${name}";
              value = {
                path = config.nix-tun.storage.persist.subvolumes."samba-shares/${name}".path;
                "read only" = "no";
                "veto files" = "/.snapshots/";
                "veto oplock files" = "/.snapshots/";
                "administrative share" = "yes";
                "vfs objects" = "btrfs shadow_copy2 acl_xattr";
                "shadow:fixinodes" = "yes";
                "shadow:localtime" = "yes";
                "shadow:format" = "${name}.%Y%m%dT%H%M%S%z";
                "shadow:snapdir" = ".snapshots";
                "shadow:crossmountpoints" = "yes";
                "shadow:mountpoint" = config.nix-tun.storage.persist.subvolumes."samba-shares/${name}".path;
                "inherit permissions" = "yes";
                "inherit owner" = "yes";
              } // value;
            })
            config.astahhu.services.samba.fs.shares);
      };
    }
  );
}
