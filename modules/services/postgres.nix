{ pkgs, config, lib, ... }: {
  options = {
    astahhu.services.postgres = {
      enable = lib.mkEnableOption ''
        Enable Postgres on this server.
        Postgres will be reachable under \$\{config.networking.hostname\}.\$\{config.networking.domain\}:5432.
      '';
      acme = {
        enable = lib.mkEnableOption ''
          Enable ACME for Postgres.
          Currently only via Cloudflare DNS Setup.
          Requires Valid Cloudflare Access Token, as Secret "postgres-cloudflare-acme"
        '';
        email = lib.mkOption {
          type = lib.types.listOf lib.types.str;
        };
      };
      databases = lib.mkOption {
        description = ''
          Databases which should be created.
          NOTE:
          For each Database a corresponding user with the same name will be created.
          And the Secret postgresql-$\{database-name\}-pw,
          will be used as password for the user.
          Existing Databases and Users will not be automatically deleted.
        '';
        type = lib.types.listOf lib.types.str;
      };
    };
  };

  config = lib.mkIf config.astahhu.services.postgres.enable {

    services.postgresql = {
      package = pkgs.postgresql_17;
      enable = true;
      initdbArgs = [ "--locale=C" "--encoding=UTF8" ];
      enableTCPIP = true;
      settings = {
        "ssl" = "on";
        "ssl_cert_file" = "";
        "ssl_key_file" = "";
        "wal_level" = "replica";
        "max_wal_senders" = 10;
        "wal_keep_size" = "1GB";
      };
      ensureDatabases = config.astahhu.services.postgres.databases;
      ensureUsers =
        ((lib.map
          (name: {
            name = name;
            ensureDBOwnership = true;
          })
          config.astahhu.services.postgres.databases) ++ [
          {
            name = "repluser";
            ensureClauses.replication = true;
          }
        ]);
      authentication = ''
        host replication repluser 134.99.154.0/24 md5
        host sameuser all 134.99.154.0/24 md5
      '';
    };

    systemd.services.samba-tls = lib.mkIf config.astahhu.services.postgres.acme.enable {
      serviceConfig = {
        Type = "oneshot";
      };

      script = ''
        cp /var/lib/acme/postgres/key.pem /var/lib/postgresql/17/server.key
        cp /var/lib/acme/samba/cert.pem /var/lib/postgresql/17/server.crt
        chmod 600 /var/lib/postgresql/17/server.key
        chmod 600 /var/lib/postgresql/17/server.crt
        chown postgres:postgres /var/lib/postgresql/17/server.key
        chown postgres:postgres /var/lib/postgresql/17/server.crt
      '';

      requires = [
        "acme-postgres.service"
      ];

      before = [
        "postgresql.target"
      ];
    };

    security.acme = lib.mkIf config.services.postgresql.acme.enable {
      acceptTerms = true;
      certs.postgres = {
        email = config.services.postgresql.acme.email;
        domain = "${lib.strings.toLower config.networking.hostname}.${config.networking.domain}";
        dnsResolver = "134.99.128.5";
        dnsProvider = "cloudflare";
        extraLegoFlags = [
          "-dns.propagation-disable-ans=true"
          "--dns.propagation-rns=true"
        ];
        dnsPropagationCheck = true;
        group = "root";
        environmentFile = config.sops.secrets.cloudflare-dns.path;
      };
    };

    sops.secrets = lib.mkMerge
      (lib.map
        (name: {
          "postgresql-${name}-pw" = {
            owner = "postgres";
          };
        })
        (config.astahhu.services.postgres.databases ++ [ "repluser" ])
      );

    systemd.services.postgresql-setup.script = lib.mkAfter (lib.strings.concatLines
      (lib.map
        (name:
          "sed '$a\\' ${config.sops.secrets."postgresql-${name}-pw".path} ${config.sops.secrets."postgresql-${name}-pw".path} | psql -tAc '\\password ${name}'"
        )
        (config.astahhu.services.postgres.databases ++ [ "repluser" ])));


    networking.firewall.allowedTCPPorts = [ 5432 ];
  };
}
