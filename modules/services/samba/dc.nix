{ config
, pkgs
, lib
, ...
}: {
  options = {
    astahhu.services.samba.dc = {
      enable = lib.mkEnableOption "Enable Samba Domain Controller";
      primary = lib.mkEnableOption ''
        Whether this is the primary domain controller, or a replica.
        Only on the primary controller can sysvol be edited, so if it is missing sysvol can only be read.
      '';
      dhcp = {
        enable = lib.mkEnableOption "Enable Kea DHCP on this DC";
        dns-servers = lib.mkOption {
          description = "List of the dns servers for the Domain";
          type = lib.types.listOf lib.types.str;
        };
        time-servers = lib.mkOption {
          description = "List of the dns servers for the Domain";
          type = lib.types.listOf lib.types.str;
        };
        routers = lib.mkOption {
          description = "External routers/gateways for the ip range";
          type = lib.types.listOf lib.types.str;
        };
        subnet = lib.mkOption {
          description = "Subnet of the DHCP in the Format a.b.c.d/x";
          type = lib.types.str;
        };
        pool = lib.mkOption {
          description = "Address pool from which the dhcp server assigns ip-addresses. Format: \"a.a.a.a - b.b.b.b\"";
          type = lib.types.str;
        };
      };
      dns = {
        forwarders = lib.mkOption {
          description = "The DNS servers to be used for requests not belonging to the domain";
          type = lib.types.listOf lib.types.str;
        };
        dnssec-validation = lib.mkOption {
          description = "The dnssec-validation option in bind";
          default = "no";
          type = lib.types.str;
        };
      };
    };
  };

  config =
    let
      cfg = config.astahhu.services.samba;
    in
    lib.mkIf cfg.dc.enable {

      security.pam.krb5.enable = false;

      environment.systemPackages = [
        pkgs.dig.out
        pkgs.dnsutils
      ];

      users.users.kea = {
        isSystemUser = true;
        group = "kea";
      };

      users.groups.kea = { };

      nix-tun.storage.persist.subvolumes.kea = {
        #bindMountDirectories = true;
        owner = "kea";
        directories = {
          "/var/lib/kea" = {
            mode = "0700";
          };
        };
      };

      systemd.services.kea-dhcp4-server.serviceConfig.DynamicUser = lib.mkForce false;

      services.kea = lib.mkIf config.astahhu.services.samba.dc.dhcp.enable {
        # DDNS via DHCP, with kerberos Authentication
        # Following the example at: https://kea.readthedocs.io/en/kea-2.7.5/arm/integrations.html#gss-tsig
        #  dhcp-ddns = {
        #    enable = false;
        #    # IP + Port for NameChange Requests 
        #    ip-address = "127.0.0.1";
        #    port = "53001";
        #    forward-ddns = {
        #      ddns-domains = [
        #        {
        #          name = cfg.domain;
        #          comment = "DDNS for ${cfg.domain}";
        #          dns-servers = [
        #            {
        #              ip-address = "127.0.0.1";
        #            }
        #          ];
        #        }
        #      ];
        #    };

        #   reverse-ddns = {
        #    ddns-domains = [
        #     {
        #      name = "154.99.134.in-addr.arpa";
        #     dns-servers = [
        #      {
        #        ip-address = "127.0.0.1";
        #      }
        #    ];
        #  }
        #];
        #};
        #};

        dhcp4 = {
          enable = true;
          settings = {
            valid-lifetime = 4000;
            renew-timer = 1000;
            rebind-timer = 2000;

            interfaces-config = {
              interfaces = [
                "eth0"
              ];
            };

            lease-database = {
              name = "/var/lib/kea/dhcp4.leases";
              persist = true;
              type = "memfile";
            };

            subnet4 = [
              {
                id = 1;
                option-data = [
                  {
                    name = "domain-name-servers";
                    csv-format = true;
                    data = lib.strings.concatStringsSep ", " cfg.dc.dhcp.dns-servers;
                  }
                  {
                    name = "routers";
                    csv-format = true;
                    data = lib.strings.concatStringsSep ", " cfg.dc.dhcp.routers;
                  }
                  {
                    name = "time-servers";
                    csv-format = true;
                    data = lib.strings.concatStringsSep ", " cfg.dc.dhcp.time-servers;
                  }
                  {
                    name = "domain-name";
                    data = cfg.domain;
                  }
                ];
                pools = [
                  {
                    pool = cfg.dc.dhcp.pool;
                  }
                ];
                subnet = cfg.dc.dhcp.subnet;
                reservations = import ./dhcp.nix;
              }
            ];
          };
        };
      };

      services.bind = {
        enable = true;

        cacheNetworks = [
          "134.99.154.0/24"
          "127.0.0.0/8"
        ];

        ipv4Only = true;

        forwarders = cfg.dc.dns.forwarders;

        extraOptions = ''
          allow-update {
            none;
          };
          dnssec-validation ${cfg.dc.dns.dnssec-validation};
          tkey-gssapi-keytab "/var/lib/samba/bind-dns/dns.keytab";
          minimal-responses yes;
        '';

        extraConfig = ''
          include "/var/lib/samba/bind-dns/named.conf";
        '';
      };

      systemd.services.bind = {
        serviceConfig = {
          ReadWritePaths = [ "/var/lib/samba/bind-dns" ];
        };
        environment = {
          # Fixes a Segfault in bind + samba 4.20.* see: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1074378
          LDB_MODULES_DISABLE_DEEPBIND = "true";
        };
      };

      # Disable default Samba `smbd` service, we will be using the `samba` server binary
      # Because the normal service can not be used for a dc
      systemd.services.samba = {
        restartTriggers = [
          config.environment.etc."samba/smb.conf".source
        ];
        description = "Samba Service Daemon";

        script = ''
          ${pkgs.samba4Full}/sbin/samba --foreground --no-process-group
        '';

        requires = lib.mkIf cfg.acme.enable [
          "acme-finished-samba.target"
        ];

        requiredBy = [
          "samba.target"
        ];
        partOf = [
          "samba.target"
        ];

        serviceConfig = {
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
        winbindd.enable = false;
        smbd.enable = false;
        nmbd.enable = false;
        package = pkgs.samba4Full;
        openFirewall = true;

        settings = {
          global = {
            "server role" = "active directory domain controller";
            "ad dc functional level" = "2016";
            "server services" = "s3fs, rpc, nbt, wrepl, ldap, cldap, kdc, drepl, winbindd, ntp_signd, kcc, dnsupdate";
            "idmap_ldb:use rfc2307" = "yes";
            "nsupdate command" = "${pkgs.dnsutils}/bin/nsupdate -g";
          };
          sysvol = {
            path = "/var/lib/samba/sysvol";
            "read only" = if cfg.dc.primary then "no" else "yes";
          };
          netlogon = {
            path = "/var/lib/samba/sysvol/${cfg.domain}/scripts";
            "read only" = if cfg.dc.primary then "no" else "yes";
          };
        };
      };

      environment.etc."resolv.conf".text = ''
        search ${cfg.domain}
        nameserver 127.0.0.1
      '';

      environment.etc."hosts".text = lib.mkForce ''
        127.0.0.1 localhost
        ${(lib.elemAt config.networking.interfaces.eth0.ipv4.addresses 0).address} ${cfg.hostname}.${cfg.domain} ${cfg.hostname}
      '';

      networking = {
        resolvconf.enable = false;

        # Ports for a samba dc
        firewall = {
          allowedTCPPorts = [
            53 # DNS
            88 # Kerberos
            123 # ntp
            135 # End Point Mapper
            139 # NetBIOS Session
            389 # LDAP
            445 # SMB over TCP
            464 # Kerberos kpasswd
            636 # LDAPS
            953 # DNS
            3268 # Global Catalog
            3269 # Global Catalog SSL
          ];

          # Dynamic RPC Ports
          allowedTCPPortRanges = [
            {
              from = 49152;
              to = 65535;
            }
          ];

          allowedUDPPorts = [
            53 # DNS
            88 # Kerberos
            123 # ntp
            137 # NetBIOS Name Service
            138 # NetBIOS Datagram
            389 # LDAP
            464 # Kerberos kpasswd
          ];
        };
      };
    };
}

