{ pkgs, config, lib, ... }: {
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

    sops.secrets.vaultwarden-env = { };
    sops.secrets.vaultwarden-ldap-pass = { };
    sops.secrets.vaultwarden-client-id = { };
    sops.secrets.vaultwarden-client-secret = { };

    containers.vaultwarden = {
      bindMounts."${config.sops.secrets.vaultwarden-env.path}" = {
        hostPath = config.sops.secrets.vaultwarden-env.path;
      };
      bindMounts."${config.sops.secrets.vaultwarden-ldap-pass.path}" = {
        hostPath = config.sops.secrets.vaultwarden-ldap-pass.path;
      };
      bindMounts."${config.sops.secrets.vaultwarden-client-id.path}" = {
        hostPath = config.sops.secrets.vaultwarden-client-id.path;
      };
      bindMounts."${config.sops.secrets.vaultwarden-client-secret.path}" = {
        hostPath = config.sops.secrets.vaultwarden-client-secret.path;
      };
    };
    nix-tun.utils.containers.vaultwarden = {
      volumes = {
        "/var/lib/vaultwarden" = { };
      };
      domains = {
        vaultwarden = {
          domain = config.astahhu.services.vaultwarden.domain;
          port = 8000;
        };
      };
      config = { ... }: {
        boot.isContainer = true;

        services.vaultwarden = {
          enable = true;
          environmentFile = config.sops.secrets.vaultwarden-env.path;
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
            ldap = config.sops.secrets.vaultwarden-ldap-pass.path;
            client_path_id = config.sops.secrets.vaultwarden-client-id.path;
            client_path_secret = config.sops.secrets.vaultwarden-client-secret.path;
          };
        };
        networking.firewall.allowedTCPPorts = [ 8000 ];
      };
    };
  };
}
