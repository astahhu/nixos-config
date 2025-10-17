{ config, lib, pkgs, ... }: {

  imports = [
    ./dc.nix
    ./fileserver.nix
  ];

  options.astahhu.services.samba = {
    enable = lib.mkEnableOption "enables the samba module";
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "The netbios name of the host, defaults to hostname, can not be longer than 15 characters";
      defaultText = "lib.strings.toUpper config.networking.hostName";
    };
    server_address = lib.mkOption {
      type = lib.types.str;
      description = "The ip addresses under which this server is reachable";
      default = "";
    };
    package = lib.mkPackageOption pkgs "samba4Full" { };
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The Kerberos/AD Domain";
      defaultText = "config.networking.domain";
    };
    workgroup = lib.mkOption {
      type = lib.types.str;
      description = "Sets the windows workgroup, has a maximum length of 15 characters";
      default = "WORKGROUP";
    };
    wsdd = lib.mkOption {
      type = lib.types.bool;
      description = "Enables network discovery for this host";
      default = true;
    };
    acme = {
      enable = lib.mkEnableOption "Enables the creation of acme certificates for samba, currently only via cloudflare";
      email = lib.mkOption {
        type = lib.types.str;
        description = "The Email to be used for acme";
      };
    };
  };

  config =
    let cfg = config.astahhu.services.samba;
    in lib.mkIf cfg.enable {

      astahhu.services.samba = {
        hostname = lib.mkOptionDefault (lib.strings.toUpper config.networking.hostName);
        domain = lib.mkOptionDefault config.networking.domain;
      };

      nix-tun.storage.persist.subvolumes = {
        samba = {
          bindMountDirectories = true;
          directories = {
            "/var/lib/samba" = { };
            "/var/lock/samba" = { };
          };
        };
        acme = {
          owner = "acme";
          bindMountDirectories = true;
          backup = false;
          directories."/var/lib/acme" = { };
        };

      };

      security.acme = lib.mkIf cfg.acme.enable {
        acceptTerms = true;
        certs.samba = {
          email = cfg.acme.email;
          domain = "${lib.strings.toLower cfg.hostname}.${cfg.domain}";
          dnsResolver = "134.99.128.5";
          dnsProvider = "cloudflare";
          extraLegoFlags = [
            "-dns.propagation-disable-ans=true"
            "--dns.propagation-rns=true"
          ];
          dnsPropagationCheck = true;
          group = "root";
          environmentFile = config.sops.secrets.cloudflare-dns.path;
          postRun = lib.mkIf cfg.acme.enable ''
            systemctl restart samba.target
          '';
        };
      };

      systemd.services.samba-tls = lib.mkIf cfg.acme.enable {
        serviceConfig = {
          Type = "oneshot";
        };

        script = ''
          cp /var/lib/acme/samba/key.pem  /var/lib/samba/private/tls/key.pem
          cp /var/lib/acme/samba/cert.pem /var/lib/samba/private/tls/cert.pem
          chmod 600 /var/lib/samba/private/tls/key.pem
          chmod 600 /var/lib/samba/private/tls/cert.pem 
          chown root:root  /var/lib/samba/private/tls/key.pem
          chown root:root  /var/lib/samba/private/tls/cert.pem  
        '';

        requires = lib.mkIf cfg.acme.enable [
          "acme-samba.service"
        ];

        before = [
          "samba.target"
        ];
      };

      security.krb5 = {
        enable = true;
        settings = {
          libdefaults = {
            default_realm = lib.strings.toUpper cfg.domain;
            dns_lookup_realm = false;
            dns_lookup_kdc = true;
          };
          realms = {
            "${lib.strings.toUpper cfg.domain}" = {
              "default_domain" = cfg.domain;
            };

            "${cfg.workgroup}" = {
              "default_domain" = cfg.domain;
            };
          };
          "domain_realm" = {
            "${cfg.hostname}" = lib.strings.toUpper cfg.domain;
          };
        };
      };

      services.samba-wsdd = lib.mkIf cfg.wsdd {
        enable = true;
        openFirewall = true;
        domain = cfg.domain;
        hoplimit = 4;
      };

      services.samba.settings.global = {
        "allow dcerpc auth level connect" = "no";
        "netbios name" = cfg.hostname;
        "restrict anonymous" = 2;
        "log level" = "0";
        "disable netbios" = "yes";
        "realm" = cfg.domain;
        "workgroup" = cfg.workgroup;
        "tls keyfile" = "tls/key.pem";
        "tls certfile" = "tls/cert.pem";
        "tls cafile" = if cfg.acme.enable then "" else "tls/ca.pem";
      };
    };


}

