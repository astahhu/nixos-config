{ pkgs, config, lib, ... }: {
  options.astahhu.services.pretix = {
      enable = lib.mkEnableOption "pretix";
      hostname = lib.mkOption {
              description = "pretix";
              type = lib.types.str;
            };
      email = lib.mkOption {
        description = "from email address";
        type = lib.types.str;
      };
    };

    config = lib.mkIf config.astahhu.services.pretix.enable {
      nix-tun.services.traefik.services.pretix.router.tls.enable = false;

      sops.secrets.postgresql-pretix-pw = {
        mode = "600";
      };

      sops.templates.pretix-pgpass = {
        mode = "600";
        uid = config.containers.pretix.config.users.users.pretix.uid;
        content = ''
          *:*:pretix:pretix:${config.sops.placeholder.postgresql-pretix-pw}
          '';
        };

      nix-tun.utils.containers.pretix = {
        volumes = {};
        domains = {
          pretix = {
            domain = config.astahhu.services.pretix.hostname;
            port = 80;
          };
        };

        config = { ... }: {
          boot.isContainer = true;
          services.pretix = {
            enable = true;
            nginx.domain = config.astahhu.services.pretix.hostname;
            settings = {
              mail.from = "${config.astahhu.services.pretix.email}";
              pretix = {
                instance_name = config.astahhu.services.pretix.hostname;
                url = "https://${config.astahhu.services.pretix.hostname}";
              };
              database = {
                host = "nix-postgresql.ad.astahhu.de";
                passfile = config.sops.templates.pretix-pgpass.path;
              };
            };
          };
        };
      };

    containers."pretix" = {
      bindMounts = {
        "pretix-pgpass" = {
          hostPath = config.sops.templates.pretix-pgpass.path;
          mountPoint = config.sops.templates.pretix-pgpass.path;
        };
      };
    };
   };
}
