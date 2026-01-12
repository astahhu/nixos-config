{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    astahhu.services.vaultwarden = {
      enable = lib.mkEnableOption "Enable vaultwarden on this server";
      domain = lib.mkOption {
        description = "The domain from which vaultwarden should be reached";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf config.astahhu.services.vaultwarden.enable {
    nix-tun.services.traefik.services.vaultwarden-vaultwarden.router.tls.enable = false;

    nix-tun.utils.containers.vaultwarden = {
      secrets = [
        "env"
        "ldap-pass"
        "client-id"
        "client-secret"
      ];
      volumes = {
        "/var/lib/bitwarden_rs" = {
          owner = "vaultwarden";
          group = "vaultwarden";
        };
      };
      domains = {
        vaultwarden = {
          domain = config.astahhu.services.vaultwarden.domain;
          port = 8000;
        };
      };
      config =
        { ... }:
        {
          boot.isContainer = true;
          users.users.vaultwarden.uid = 996;

          services.vaultwarden = {
            enable = true;
            environmentFile = "/secret/env";
          };

          services.bitwarden-directory-connector-cli = {
            enable = true;
            domain = "https://" + config.astahhu.services.vaultwarden.domain;
            ldap = {
              username = "vaultwarden-connector";
              ad = true;
              hostname = "ad.astahhu.de";
              ssl = true;
              rootPath = "dc=ad,dc=astahhu,dc=de";
            };
            sync = {
              users = true;
              groups = true;
              groupPath = "ou=AStA";
              userPath = "ou=AStA";
              userFilter = "(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=ad,DC=astahhu,DC=de)";
            };
            secrets = {
              ldap = "/secret/ldap-pass";
              bitwarden = {
                client_path_id = "/secret/client-id";
                client_path_secret = "/secret/client-secret";
              };
            };
          };
          networking.firewall.allowedTCPPorts = [ 8000 ];
        };
    };
  };
}
