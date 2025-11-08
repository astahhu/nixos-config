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
        "db-pass"
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
            http-port = "80";
            http-enabled = true;
            https-enabled = false;
            hostname = config.astahhu.services.keycloak.domain;
          };
          initialAdminPassword = "uekoajaeRae0eegh0phee9phohx6ahp8aangai8sae1Thun2xai5Hah3vee7Ooje";
          database = {
            username = "keycloak";
            type = "postgresql";
            name = "keycloak";
            host = "nix-postgresql.ad.astahhu.de";
            passwordFile = "/secret/db-pass";
            useSSL = false;
          };
        };
        networking.firewall.allowedTCPPorts = [ 80 ];
      };
    };
  };
}
