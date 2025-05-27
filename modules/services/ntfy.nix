{ pkgs, config, lib, ... }: {
  options = {
    astahhu.services.ntfy = {
      enable = lib.mkEnableOption "Enable Ntfy on this server";
      domain = lib.mkOption {
        description = "The domain from which ntfy should be reached";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf config.astahhu.services.vaultwarden.enable {

    sops.secrets.grafana-ntfy-pass = { };

    containers.ntfy = {
      bindMounts."${config.sops.secrets.grafana-ntfy-pass.path}" = {
        hostPath = config.sops.secrets.grafana-ntfy-pass.path;
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
      config = { ... }: {
        boot.isContainer = true;
        networking.firewall.allowedTCPPorts = [ 8000 ];

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
