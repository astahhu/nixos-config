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
    nix-tun.services.traefik.services.pretix-pretix.router.tls.enable = false;

    nix-tun.utils.containers.pretix = {
      secrets = [
        "env"
      ];
      volumes = { };
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
          environmentFile = "/secret/env";
          database.createLocally = false;
          nginx.domain = config.astahhu.services.pretix.hostname;
          settings = {
            mail.from = "${config.astahhu.services.pretix.email}";
            pretix = {
              instance_name = config.astahhu.services.pretix.hostname;
              url = "https://${config.astahhu.services.pretix.hostname}";
            };
            database = {
              host = "nix-postgresql.ad.astahhu.de";
            };
          };
        };
      };
    };
  };
}
