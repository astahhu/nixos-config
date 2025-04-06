{ pkgs, config, lib, ... }: {
  options = {
    astahhu.common.enable-node-exporter = lib.mkEnableOption ''
      Whether to monitor this system, with Prometheus Node Exporter Endpoints.
      The default entrypoint for this is `node-exporter.$\{config.networking.fqdnOrHostName\}` at port 9100.
      Basic Auth is used to authenticate to the service.
      This uses the value of `config.sops.secrets."node-exporter-pw"` as hashed password for the user `node-exporter`.
    '';
  };
  config = lib.mkIf config.astahhu.common.enable-node-exporter {
    nix-tun.services.traefik = {
      entrypoints = {
        "node-exporter" = {
          port = 9100;
        };
        web = {
          port = 80;
          http = {
            redirections = {
              entryPoint = {
                to = "websecure";
                scheme = "https";
              };
            };
          };
        };
        websecure = {
          port = 443;
        };
      };
      services.node-exporter = {
        servers = [ "http://node-exporter.containers:9100" ];
        router = {
          entryPoints = [ "node-exporter" ];
          rule = "Host(`${config.networking.fqdnOrHostName}`)";
          tls.enable = false;
        };
      };
    };

    sops.secrets."node-exporter-pw" = { };
    sops.templates."node-exporter-auth" = {
      owner = "traefik";
      content = ''
        node-exporter:${config.sops.placeholder.node-exporter-pw}
      '';
    };

    services.traefik.dynamicConfigOptions.http.middlewares."node-exporter-auth".basicAuth = {
      usersFile = config.sops.templates."node-exporter-auth".path;
    };

    containers.node-exporter = {
      autoStart = true;
      timeoutStartSec = "5min";
      privateNetwork = true;
      hostAddress = "192.168.100.10";
      localAddress = "192.168.100.13";
      bindMounts = {
        "/host" = {
          hostPath = "/";
          isReadOnly = true;
        };
      };
    };


    nix-tun.utils.containers.node-exporter = {
      config = {
        systemd.services.prometheus-node-exporter.serviceConfig.BindPaths = "/host/run/dbus:/run/dbus";
        services.prometheus.exporters.node = {
          openFirewall = true;
          enable = true;
          enabledCollectors = [
            "systemd"
            "network_route"
          ];
          extraFlags = [
            "--path.rootfs=/host/"
            "--path.sysfs=/host/sys"
            "--path.procfs=/host/proc"
            "--path.udev.data=/host/run/udev/data"
          ];
        };
      };
    };
  };
} 
