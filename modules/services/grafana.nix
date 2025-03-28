{ pkgs, config, lib, ... }: {
  options = {
    astahhu.services.grafana = {
      enable = lib.mkEnableOption "Enable grafana on this server";
      domain = lib.mkOption {
        description = "The domain from which grafana should be reached";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf config.astahhu.services.grafana.enable {
    containers.grafana = {
      autoStart = true;
      privateNetwork = true;
      timeoutStartSec = "5min";
      hostAddress = "192.168.100.10";
      localAddress = "192.168.100.12";
    };

    nix-tun.services.traefik.services."grafana" = {
      router.rule = "Host(`${config.astahhu.services.grafana.domain}`)";
      router.tls.enable = false;
      servers = [ "http://grafana.containers:3000" ];
    };

    nix-tun.utils.containers.grafana = {
      volumes = {
        "/var/lib/grafana" = { };
      };
      config = { ... }: {
        boot.isContainer = true;
        services.grafana = {
          enable = true;
          settings = {
            server = {
              domain = "grafana.astahhu.de";
              http_addr = "0.0.0.0";
              root_url = "https://grafana.astahhu.de";
            };
            "auth.basic".enable = false;
            auth.disable_login_form = true;
            "auth.generic_oauth" = {
              enabled = true;
              name = "AStA Intern";
              allow_sign_up = true;
              client_id = "grafana";
              scopes = "openid email profile offline_access roles";
              email_attribute_path = "email";
              login_attribute_path = "username";
              name_attribute_path = "full_name";
              auth_url = "https://keycloak.astahhu.de/realms/astaintern/protocol/openid-connect/auth";
              token_url = "https://keycloak.astahhu.de/realms/astaintern/protocol/openid-connect/token";
              api_url = "https://keycloak.astahhu.de/realms/astaintern/protocol/openid-connect/userinfo";
              role_attribute_path = "contains(roles[*], 'admin') && 'Admin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'";
            };
          };
        };
        networking.firewall.allowedTCPPorts = [ 3000 ];
      };
    };
  };
}
