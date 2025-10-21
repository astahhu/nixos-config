{ pkgs, config, lib, ... }: {
  options = {
    astahhu.services.keycloak = {
      enable = lib.mkEnableOption "Enable keycloak on this server";
      domain = lib.mkOption {
        description = "The domain from which keycloak should be reached";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf config.astahhu.services.keycloak.enable {
    nix-tun.services.traefik.services.keycloak-keycloak.router.tls.enable = false;

    nix-tun.utils.containers.keycloak = {
      secrets = [
        "db_pass"
      ];
      volumes = {
        "/var/lib/private/keycloak" = {
          owner = "-";
          group = "-";
        };
      };
      domains = {
        keycloak = {
          domain = config.astahhu.services.keycloak.domain;
          port = 80;
        };
      };
      config = { ... }: {
        boot.isContainer = true;
        services.keycloak = {
          enable = true;
          settings = {
            http-host = "0.0.0.0";
          };
          initialAdminPassword = "initialAdminPassword";
          database = {
            username = "keycloak";
            type = "postgresql";
            name = "keycloak";
            host = "nix-postgresql.ad.astahhu.de";
            passwordFile = "/secret/db_pass";
          };
        };
        networking.firewall.allowedTCPPorts = [ 80 ];
      };
    };
  };
}
