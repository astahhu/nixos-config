{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
{
  options = {
    astahhu.services.ntfy = {
      enable = lib.mkEnableOption "Enable Ntfy on this server";
      domain = lib.mkOption {
        description = "The domain from which ntfy should be reached";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf config.astahhu.services.ntfy.enable {

    sops.secrets.grafana-ntfy-pass = { };
    sops.secrets.grafana-to-ntfy = {
      sopsFile = ../../secrets/nix-webserver.yaml;
      key = "grafana-2-ntfy-env";
    };

    containers.ntfy = {
      bindMounts."${config.sops.secrets.grafana-ntfy-pass.path}" = {
        hostPath = config.sops.secrets.grafana-ntfy-pass.path;
      };
      bindMounts."${config.sops.secrets.grafana-to-ntfy.path}" = {
        hostPath = config.sops.secrets.grafana-to-ntfy.path;
      };

    };
    nix-tun.utils.containers.ntfy = {
      volumes = {
        "/var/lib/ntfy" = { };
      };
      domains = {
        ntfy = {
          domain = config.astahhu.services.ntfy.domain;
          port = 8080;
        };
      };
      config =
        { ... }:
        {
          boot.isContainer = true;
          networking.firewall.allowedTCPPorts = [ 8000 ];

          systemd.services.grafana-to-ntfy = {
            after = [ "network.target" ];
            path = [ pkgs.bash ];
            script = "${lib.getExe inputs.grafana2ntfy.packages.${pkgs.stdenv.system}.default}";
            serviceConfig = {
              Restart = "always";
              RestartSec = 5;
              EnvironmentFile = config.sops.secrets.grafana-to-ntfy.path;
            };
            wantedBy = [ "multi-user.target" ];
          };
          services.ntfy-sh = {
            enable = true;
            settings = {
              behind-proxy = true;
              base-url = "https://${config.astahhu.services.ntfy.domain}";
              listen-http = ":8080";
              #auth-default-access = "deny-all";
              ntfyBAuthUser = "grafana";
              ntfyBAuthPass = config.sops.secrets.grafana-ntfy-pass.path;
            };
          };
        };
    };
  };
}
