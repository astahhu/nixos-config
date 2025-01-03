{ config
, pkgs
, lib
, ...
}: {
  options = {
    astahhu.services.samba-dc = {
      enable = lib.mkEnableOption "Enable Samba Domain Controller";
      name = lib.mkOption {
        type = lib.types.str;
        description = "The Netbios Name of the Domain Controller";
      };
    };
  };

  config = lib.mkIf config.astahhu.services.samba-dc.enable
    {

      environment.systemPackages = [
        pkgs.dig.out
        pkgs.dnsutils
      ];

      nix-tun.storage.persist.subvolumes =
        {
          samba = {
            bindMountDirectories = true;
            directories = {
              "/var/lib/samba" = { };
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
          realms = {
            "AD.ASTAHHU.DE" = {
              "default_domain" = "ad.astahhu.de";
            };
          };
          "domain_realm" = {
            "NIX-SAMBA-DC" = "AD.ASTAHHU.DE";
          };
        };
      };

      systemd.services.resolvconf.enable = false;

      # Disable default Samba `smbd` service, we will be using the `samba` server binary
      systemd.services.samba-smbd.enable = false;
      systemd.services.samba = {
        restartTriggers = [
          config.services.samba
        ];
        description = "Samba Service Daemon";

        requiredBy = [ "samba.target" ];
        partOf = [ "samba.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.samba4Full}/sbin/samba --foreground --no-process-group";
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          LimitNOFILE = 16384;
          PIDFile = "/run/samba.pid";
          Type = "notify";
          NotifyAccess = "all"; #may not do anything...
        };
        unitConfig.RequiresMountsFor = "/var/lib/samba";
      };

      services.samba = {
        enable = true;
        enableNmbd = false;
        enableWinbindd = false;
        package = pkgs.samba4Full;
        openFirewall = true;


        settings = {
          global =
            {
              "netbios name" = config.astahhu.services.samba-dc.name;
              "realm" = "AD.ASTAHHU.DE";
              "server role" = "active directory domain controller";
              "server services" = "s3fs, rpc, nbt, wrepl, ldap, cldap, kdc, drepl, winbindd, ntp_signd, kcc, dnsupdate";
              "workgroup" = "AD.ASTAHHU";
              "idmap_ldb:use rfc2307" = "yes";
              "nsupdate command" = "${pkgs.dnsutils}/bin/nsupdate -g";
              "tls enabled" = "yes";
              "tls keyfile" = "tls/key.pem";
              "tls certfile" = "tls/cert.pem";
              "tls cafile" = "tls/ca.pem";
            };
          sysvol = {
            path = "/var/lib/sysvol";
            "read only" = "yes";
          };
          netlogon = {
            path = "/var/lib/samba/sysvol/ad.astahhu.de/scripts";
            "read only" = "yes";
          };
        };
      };
    };
}
