{ pkgs, config, lib, ... }: {
  options = {
    astahhu.services.grafana = {
      enable = lib.mkEnableOption "Enable grafana on this server";
      domain = lib.mkOption {
        description = "The domain from which grafana should be reached";
        type = lib.types.str;
      };
      prometheus = {
        scrapeConfigs = lib.mkOption {
          type = lib.types.attrs;
        };
        domain = lib.mkOption {
          description = "The domain from which prometheus should be reached";
          type = lib.types.str;
        };
      };
    };
  };

  config = lib.mkIf config.astahhu.services.grafana.enable {
    containers.grafana = {
      autoStart = true;
      privateNetwork = true;
      timeoutStartSec = "5min";
      bindMounts."${config.sops.secrets.node-exporter-pass.path}" = {
        hostPath = config.sops.secrets.node-exporter-pass.path;
      };
    };

    nix-tun.services.traefik.services."grafana-grafana" = {
      router.tls.enable = false;
    };

    sops.secrets.node-exporter-pass = {
      uid = config.containers.grafana.config.users.users.grafana.uid;
    };

    nix-tun.utils.containers.grafana = {
      volumes = {
        "/var/lib/grafana" = { };
        "/var/lib/prometheus2" = { };
      };
      domains = {
        grafana = {
          domain = config.astahhu.services.grafana.domain;
          port = 3000;
        };
      };
      config = { ... }: {
        boot.isContainer = true;
        services.prometheus = {
          enable = true;
          port = 9000;
          scrapeConfigs = [{
            job_name = "nix-webserver-metrics";
            #basic_auth = {
            #  username = "node-exporter";
            #  password_file = config.sops.secrets.node-exporter-pass.path;
            #};
            #tls_config.insecure_skip_verify = true;
            static_configs = [{
              targets = [
                "node-exporter:9100"
                "nix-nextcloud.ad.astahhu.de:9100"
              ];
            }];
          }];
        };

        services.grafana = {
          enable = true;
          settings = {
            server = {
              domain = config.astahhu.services.grafana.domain;
              http_addr = "0.0.0.0";
              root_url = "https://${config.astahhu.services.grafana.domain}";
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
              role_attribute_path = "contains(roles[*], 'Admin') && 'Admin' || contains(roles[*], 'Editor') && 'Editor' || 'Viewer'";
            };
          };
        };
        networking.firewall.allowedTCPPorts = [ 3000 ];
      };
    };
  };
}
