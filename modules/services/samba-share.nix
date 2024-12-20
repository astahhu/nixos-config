{ config
, pkgs
, lib
, ...
}: {
  options = {
    astahhu.services.samba-fs = {
      enable = lib.mkEnableOption "Enable Samba Fileserver";
      shares = lib.mkOption {
        type = lib.types.attrs;
        description = "Samba Shares";
        default = { };
      };
    };
  };

  config = lib.mkIf config.astahhu.services.samba-fs.enable {
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
        config.astahhu.services.samba-fs.shares;

    nix-tun.storage.persist.subvolumes =
      lib.attrsets.mapAttrs'
        (name: value: {
          name = "samba-shares/${name}";
          value.group = "1000512";
        })
        config.astahhu.services.samba-fs.shares
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

    security.pam.krb5.enable = false;
    security.krb5 = {
      enable = true;
      settings = {
        libdefaults = {
          default_realm = "ad.astahhu.de";
          dns_lookup_realm = false;
          dns_lookup_kdc = true;
        };
        localauth = {
          module = "winbind:${config.services.samba.package}/lib/samba/krb5/winbind_krb5_localauth.so";
          enable_only = "winbind";
        };
      };
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    services.samba = {
      enable = true;
      package = pkgs.samba4Full;
      openFirewall = true;
      nsswins = true;


      settings =
        lib.mkMerge [{
          global =
            {
              "allow trusted domains" = "yes";
              "security" = "ads";
              "workgroup" = "AD.ASTAHHU";
              "realm" = "ad.astahhu.de";
              "log level" = " 0 shadow_copy:4";
              "netbios name" = "NIX-SAMBA-FS";
              "winbind refresh tickets" = true;
              "template shell" = "${pkgs.bash}";
              "idmap config * : range" = "100000 - 199999";
              "idmap config AD.ASTAHHU : backend" = "rid";
              "idmap config AD.ASTAHHU : range" = "1000000 - 1999999";
              "idmap config ASTA2012 : backend" = "rid";
              "idmap config ASTA2012 : range" = "2000000 - 2999999";
              "inherit acls" = "yes";
              "vfs objects" = "acl_xattr";
            };
        }
          (lib.attrsets.mapAttrs'
            (name: value: {
              name = "${name}";
              value = {
                path = "${config.nix-tun.storage.persist.path}/samba-shares/${name}";
                "read only" = "no";
                "veto files" = "/.snapshots/";
                "veto oplock files" = "/.snapshots/";
                "administrative share" = "yes";
                "vfs objects" = "btrfs shadow_copy2";
                "shadow:fixinodes" = "yes";
                "shadow:localtime" = "yes";
                "shadow:format" = "${name}.%Y%m%dT%H%M%S%z";
                "shadow:snapdir" = ".snapshots";
                "shadow:crossmountpoints" = "yes";
                "shadow:mountpoint" = "${config.nix-tun.storage.persist.path}/samba-shares/${name}";
              } // value;
            })
            config.astahhu.services.samba-fs.shares)];
    };
  };
}
