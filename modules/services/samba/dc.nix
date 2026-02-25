{ config
, pkgs
, lib
, ...
}:

{
  options.astahhu.services.samba.dc = {
    enable = lib.mkEnableOption "Enable Samba Domain Controller";

    primary = lib.mkEnableOption ''
      Whether this is the primary domain controller.
      Only the primary can modify sysvol.
    '';

    domain-dfs = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      default = { };
      description = ''
        Domain-wide DFS mappings.
        Format: <virtual-share>.<file> = <fileserver>/<share>
      '';
    };

    dhcp = {
      enable = lib.mkEnableOption "Enable Kea DHCP on this DC";

      dns-servers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };

      time-servers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };

      routers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };

      subnet = lib.mkOption {
        type = lib.types.str;
      };

      pool = lib.mkOption {
        type = lib.types.str;
      };
    };

    dns = {
      forwarders = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };

      dnssec-validation = lib.mkOption {
        type = lib.types.str;
        default = "no";
      };
    };
  };

  config = lib.mkIf config.astahhu.services.samba.dc.enable {

    let
      cfg = config.astahhu.services.samba;
      dc = cfg.dc;
    in
    {

      ########################################
      # ZFS Storage
      ########################################

      nix-tun.storage.persist.datasets = {

        # Samba core data (sysvol, private, etc.)
        "samba" = {
          backup = true;
          path = "${config.nix-tun.storage.persist.path}/samba";
          bindMountDirectories = true;
          directories = {
            "/var/lib/samba" = { };
            "/var/lib/samba/private" = { };
            "/var/lib/samba/sysvol" = { };
          };
        };

        # DFS datasets
        //
        (lib.mapAttrs'
          (name: _: {
            name = "samba-shares/${name}-dfs";
            value = {
              backup = true;
              path =
                "${config.nix-tun.storage.persist.path}/samba-shares/${name}-dfs";
              mode = "0555";
            };
          })
          dc.domain-dfs)

        # Kea DHCP storage
        //
        {
          "kea" = {
            backup = false;
            path = "${config.nix-tun.storage.persist.path}/kea";
            directories = {
              "/var/lib/kea" = {
                owner = "kea";
                group = "kea";
                mode = "0700";
              };
            };
          };
        };
      };

      ########################################
      # Samba Service (AD DC)
      ########################################

      services.samba = {
        enable = true;
        package = pkgs.samba4Full;
        openFirewall = true;
        smbd.enable = false;
        nmbd.enable = false;
        winbindd.enable = false;

        settings = lib.mkMerge [

          {
            global = {
              "server role" = "active directory domain controller";
              "ad dc functional level" = "2016";
              "server services" =
                "s3fs, rpc, ldap, cldap, kdc, drepl, ntp_signd, kcc, dnsupdate";

              "additional dns hostnames" = cfg.domain;
              "nsupdate command" =
                "${pkgs.dnsutils}/bin/nsupdate -g";
            };

            sysvol = {
              path = "/var/lib/samba/sysvol";
              "read only" = if dc.primary then "no" else "yes";
            };

            netlogon = {
              path = "/var/lib/samba/sysvol/${cfg.domain}/scripts";
              "read only" = if dc.primary then "no" else "yes";
            };
          }

          # DFS shares
          (lib.mapAttrs
            (name: value: {
              "${name}" = {
                "msdfs root" = "yes";
                "msdfs proxy" =
                  "${lib.strings.toLower cfg.hostname}.${cfg.domain}/${name}-dfs";
              };

              "${name}-dfs" = {
                path =
                  "${config.nix-tun.storage.persist.path}/samba-shares/${name}-dfs";
                "msdfs root" = "yes";
                "browseable" = "no";
              };
            })
            dc.domain-dfs)
        ];
      };

      ########################################
      # Bind DNS
      ########################################

      services.bind = {
        enable = true;
        forwarders = dc.dns.forwarders;
        ipv4Only = true;

        extraOptions = ''
          allow-update { none; };
          dnssec-validation ${dc.dns.dnssec-validation};
        '';

        extraConfig = ''
          include "/var/lib/samba/bind-dns/named.conf";
        '';
      };

      ########################################
      # Firewall
      ########################################

      networking.firewall.allowedTCPPorts = [
        53 88 123 135 139 389 445 464 636 953 3268 3269
      ];

      networking.firewall.allowedUDPPorts = [
        53 88 123 137 138 389 464
      ];

      networking.firewall.allowedTCPPortRanges = [
        { from = 49152; to = 65535; }
      ];
    };
  };
}
