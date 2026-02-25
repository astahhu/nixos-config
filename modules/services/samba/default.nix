{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.astahhu.services.samba;
in

{
  imports = [
    ./dc.nix
    ./fileserver.nix
  ];

  options.astahhu.services.samba = {
    enable = lib.mkEnableOption "Enables the Samba module";

    hostname = lib.mkOption {
      type = lib.types.str;
      default = lib.strings.toUpper config.networking.hostName;
      description = "NetBIOS name (max 15 characters).";
    };

    server_address = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "IP address the server is reachable at.";
    };

    package = lib.mkPackageOption pkgs "samba4Full" { };

    domain = lib.mkOption {
      type = lib.types.str;
      default = config.networking.domain;
      description = "Kerberos / AD domain.";
    };

    workgroup = lib.mkOption {
      type = lib.types.str;
      default = "WORKGROUP";
      description = "Windows workgroup (max 15 chars).";
    };

    wsdd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable network discovery.";
    };

    acme = {
      enable = lib.mkEnableOption "Enable ACME certificates for Samba";

      email = lib.mkOption {
        type = lib.types.str;
        description = "Email for ACME.";
      };
    };
  };

  config =
    lib.mkIf config.astahhu.services.samba.enable

      {

        ########################################
        # ZFS Persistence (REPLACES subvolumes)
        ########################################

        nix-tun.storage.persist.datasets = {

          samba = {
            backup = true;
            path = "${config.nix-tun.storage.persist.path}/samba";
            bindMountDirectories = true;

            directories = {
              "/var/lib/samba" = { };
              "/var/lock/samba" = { };
              "/var/lib/samba/private" = { };
            };
          };

          acme = lib.mkIf cfg.acme.enable {
            backup = false;
            path = "${config.nix-tun.storage.persist.path}/acme";
            directories = {
              "/var/lib/acme" = {
                owner = "acme";
                group = "acme";
              };
            };
          };

        };

        ########################################
        # Samba Overlay (cryptography fix)
        ########################################

        nixpkgs.overlays = [
          (final: prev: {
            samba4Full = prev.samba4Full.overrideAttrs {
              pythonPath = prev.samba4Full.pythonPath ++ [ prev.python3Packages.cryptography ];
            };
          })
        ];

        ########################################
        # ACME TLS Handling
        ########################################

        security.acme = lib.mkIf cfg.acme.enable {
          acceptTerms = true;

          certs.samba = {
            email = cfg.acme.email;
            domain = "${lib.strings.toLower cfg.hostname}.${cfg.domain}";
            dnsProvider = "cloudflare";
            environmentFile = config.sops.secrets.cloudflare-dns.path;
            group = "root";

            postRun = ''
              systemctl restart samba.target
            '';
          };
        };

        systemd.services.samba-tls = lib.mkIf cfg.acme.enable {
          serviceConfig.Type = "oneshot";

          script = ''
            install -m 600 -o root -g root \
              /var/lib/acme/samba/key.pem \
              /var/lib/samba/private/tls/key.pem

            install -m 600 -o root -g root \
              /var/lib/acme/samba/cert.pem \
              /var/lib/samba/private/tls/cert.pem
          '';

          requires = [ "acme-samba.service" ];
          before = [ "samba.target" ];
        };

        ########################################
        # Kerberos
        ########################################

        security.krb5 = {
          enable = true;
          settings = {
            libdefaults = {
              default_realm = lib.strings.toUpper cfg.domain;
              dns_lookup_realm = false;
              dns_lookup_kdc = true;
            };
          };
        };

        ########################################
        # WSDD
        ########################################

        services.samba-wsdd = lib.mkIf cfg.wsdd {
          enable = true;
          openFirewall = true;
          domain = cfg.domain;
        };

        ########################################
        # Global Samba Settings
        ########################################

        services.samba.settings.global = {
          "netbios name" = cfg.hostname;
          "realm" = cfg.domain;
          "workgroup" = cfg.workgroup;

          "disable netbios" = "yes";
          "restrict anonymous" = 2;
          "log level" = "0";

          "tls keyfile" = "private/tls/key.pem";
          "tls certfile" = "private/tls/cert.pem";
        };

      };
}
