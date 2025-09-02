{ pkgs, config, lib, ... }: {
  options = {
    astahhu.services.postgres = {
      enable = lib.mkEnableOption ''
        Enable Postgres on this server.
      '';
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


    networking.firewall.allowedTCPPorts = [ 8000 ];
  };
}
