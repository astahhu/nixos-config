{ config
, pkgs
, lib
, ...
}: {
  options.nix-tun.services.traefik = {
    enable = lib.mkEnableOption "Enable the Traefik Reverse Proxy";
    enable_prometheus = lib.mkEnableOption ''
      Enable Prometheus metrics.
      The default entrypoint for this is `traefik.$\{config.networking.fqdnOrHostName\}` at port 9100.
      Basic Auth is used to authenticate to the service.
      This uses the value of `config.sops.secrets."prometheus-traefik-pw"` as hashed password for the user `traefik`.
    '';
    enable_docker = lib.mkEnableOption "Enable Docker Discovery";
    letsencryptMail = lib.mkOption {
      type = lib.types.str;
      default = null;
      description = ''
        The email address used for letsencrypt certificates
      '';
    };
    dashboardUrl = lib.mkOption {
      type = lib.types.str;
      default = null;
      description = ''
        The url to which the dashboard should be published to
      '';
    };
    entrypoints = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        freeformType = (pkgs.formats.toml { }).type;
        options = {
          port = lib.mkOption {
            type = lib.types.port;
          };
          protocol = lib.mkOption {
            type = lib.types.enum [ "tcp" "udp" ];
            default = "tcp";
          };
          bind-ip = lib.mkOption {
            type = lib.types.str;
            default = "0.0.0.0";
          };
        };
      });
      default = { };
      description = ''
        The entryPoints config of the traefik reverse proxy. See https://doc.traefik.io/traefik/reference/install-configuration/entrypoints/ for reference.
        The address field of the traefik config is split into the three options port, protocol and bind-ip.
        So instead of 
        {
          address = "0.0.0.0:443/tcp"
        }
        you would write
        {
          port = 443;
          protocol = "tcp";
          bind-ip = "0.0.0.0";
        }
      '';
    };
    redirects =
      lib.mkOption { };
    services = lib.mkOption {
      type = lib.types.attrsOf
        (lib.types.submodule ({ ... }: {
          options = {
            protocol = lib.mkOption {
              type = lib.types.enum [ "tcp" "udp" "http" ];
              default = "http";
            };
            router = {
              rule = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = ''
                  The routing rule for this service. The rules are defined here: https://doc.traefik.io/traefik/routing/routers/
                  Only used on tcp and http routes.
                '';
              };
              priority = lib.mkOption {
                type = lib.types.int;
                default = 0;
                description = ''
                  The priority of this rule, if multiple rules match a request, the highest priority rule will be used.
                '';
              };
              tls = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = ''
                    Enable tls for router, default = true; Only for tcp and udp.
                  '';
                };
                options = lib.mkOption {
                  type = lib.types.attrs;
                  default = {
                    certResolver = "letsencrypt";
                  };
                  description = ''
                    Options for tls, default is to use the letsencrypt certResolver
                  '';
                };
              };
              middlewares = lib.mkOption {
                type = lib.types.listOf (lib.types.str);
                default = [ ];
                description = ''
                  The middlewares applied to the router, the middlewares are applied in order.
                '';
              };
              entryPoints = lib.mkOption {
                type = lib.types.listOf (lib.types.str);
                default = [ "websecure" ];
                description = ''
                  The entrypoints for the service, default is 443 websecure.
                '';
              };
            };
            servers = lib.mkOption {
              type = lib.types.listOf (lib.types.str);
              default = [ ];
              description = ''
                The hosts of the service
              '';
            };
            healthcheck = {
              enable = lib.mkEnableOption ''
                Enables healthcheck of this service from traefik.
                Traefik expects a status code of 2xx or 3xx at path.
                If the healthcheck fails the service will not be reachable.
              '';
              path = lib.mkOption {
                type = lib.types.str;
                default = "/";
                description = ''
                  The path for the healthcheck.
                '';
              };
              interval = lib.mkOption {
                type = lib.types.str;
                default = "10s";
                description = ''
                  How often the service is HealthChecked.
                '';
              };
              timeout = lib.mkOption {
                type = lib.types.str;
                default = "3s";
                description = ''
                  How long traefik waits for an response, before it deems the server unreachable.
                '';
              };
            };
          };
        }));
      default = { };
      description = ''
        A simple setup to configure http loadBalancer services and routers.
      '';
    };
  };

  config = lib.mkIf config.nix-tun.services.traefik.enable {

    environment.etc."alloy/traefik-metrics.alloy".text = lib.mkIf (config.nix-tun.alloy.prometheus-host != null && config.nix-tun.services.traefik.enable_prometheus) ''
      prometheus.scrape "traefik" {
        scrape_interval = "15s"
        targets    = [
          { "__address__" = "127.0.0.1:9100", "instance" = "constants.hostname"},
        ]
        job_name = "traefik"
        forward_to = [prometheus.remote_write.default.receiver]
      }
    '';

    nix-tun.services.traefik.entrypoints = {
      web = {
        port = 80;
        protocol = "tcp";
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
        protocol = "tcp";
      };
      prometheus = lib.mkIf config.nix-tun.services.traefik.enable_prometheus {
        bind-ip = "127.0.0.1";
        port = 9100;
        protocol = "tcp";
      };
    };

    networking.firewall.allowedTCPPorts = lib.attrsets.mapAttrsToList (name: value: value.port)
      (lib.attrsets.filterAttrs (name: value: value.protocol == "tcp" || value.protocol == "http") config.nix-tun.services.traefik.entrypoints);

    networking.firewall.allowedUDPPorts = lib.attrsets.mapAttrsToList (name: value: value.port)
      (lib.attrsets.filterAttrs (name: value: value.protocol == "udp") config.nix-tun.services.traefik.entrypoints);

    users.users.traefik.extraGroups = lib.mkIf config.nix-tun.services.traefik.enable_docker [ "docker" ];
    systemd.services.traefik.environment.LD_LIBRARY_PATH = config.system.nssModules.path;
    systemd.services.traefik.serviceConfig.LimitNPROC = lib.mkForce 8192;

    services.traefik = {
      enable = true;
      dynamicConfigOptions = {
        http = {
          routers = lib.mkMerge [
            (lib.attrsets.mapAttrs
              (
                name: value:
                  lib.mkMerge [
                    {
                      rule = value.router.rule;
                      priority = value.router.priority;
                      middlewares = value.router.middlewares;
                      service = name;
                      entryPoints = value.router.entryPoints;
                    }
                    (lib.mkIf value.router.tls.enable {
                      tls = value.router.tls.options;
                    })
                  ]
              )
              (lib.attrsets.filterAttrs
                (n: v: v.protocol == "http")
                config.nix-tun.services.traefik.services))
            (lib.mkIf config.nix-tun.services.traefik.enable_prometheus {
              prometheus-traefik = {
                rule = "ClientIP(`127.0.0.1`)";
                entryPoints = "prometheus";
                service = "prometheus@internal";
              };
            })
          ];

          services =
            lib.attrsets.mapAttrs
              (name: value: {
                loadBalancer = lib.mkMerge [{
                  servers = builtins.map (value: { url = value; }) value.servers;
                }
                  (lib.mkIf value.healthcheck.enable {
                    healthCheck = {
                      path = value.healthcheck.path;
                      interval = value.healthcheck.interval;
                      timeout = value.healthcheck.timeout;
                    };
                  })];
              })
              (lib.attrsets.filterAttrs
                (n: v: v.protocol == "http")
                config.nix-tun.services.traefik.services);
        };
        tcp = lib.mkIf
          ({ } != (lib.attrsets.filterAttrs
            (n: v: v.protocol == "tcp")
            config.nix-tun.services.traefik.services))
          {
            routers = (lib.attrsets.mapAttrs
              (
                name: value:
                  lib.mkMerge [
                    {
                      rule = value.router.rule;
                      priority = value.router.priority;
                      middlewares = value.router.middlewares;
                      service = name;
                      entryPoints = value.router.entryPoints;
                    }
                    (lib.mkIf value.router.tls.enable {
                      tls = value.router.tls.options;
                    })
                  ]
              )
              (lib.attrsets.filterAttrs
                (n: v: v.protocol == "tcp")
                config.nix-tun.services.traefik.services));

            services = lib.attrsets.mapAttrs
              (name: value: {
                loadBalancer.servers = builtins.map (value: { address = value; }) value.servers;
              })
              (lib.attrsets.filterAttrs
                (n: v: v.protocol == "tcp")
                config.nix-tun.services.traefik.services);

          };
        udp = lib.mkIf
          ({ } != (lib.attrsets.filterAttrs
            (n: v: v.protocol == "udp")
            config.nix-tun.services.traefik.services))
          {
            routers = (lib.attrsets.mapAttrs
              (name: value: {
                service = name;
                entryPoints = value.router.entryPoints;
              })
              (lib.attrsets.filterAttrs
                (n: v: v.protocol == "udp")
                config.nix-tun.services.traefik.services));

            services =
              (lib.attrsets.mapAttrs
                (
                  name: value: {
                    loadBalancer.servers = builtins.map (value: { address = value; }) value.servers;
                  }
                )
                (lib.attrsets.filterAttrs
                  (n: v: v.protocol == "udp")
                  config.nix-tun.services.traefik.services));

          };
      };

      staticConfigOptions = lib.mkMerge [
        {
          providers.docker = lib.mkIf config.nix-tun.services.traefik.enable_docker {
            exposedByDefault = false;
            watch = true;
          };
          certificatesResolvers = {
            letsencrypt = {
              acme = {
                email = config.nix-tun.services.traefik.letsencryptMail;
                storage = "/var/lib/traefik/acme.json";
                tlsChallenge = { };
              };
            };
          };

          entryPoints =
            (lib.attrsets.mapAttrs
              (name: value: {
                address = "${value.bind-ip}:${toString value.port}/${value.protocol}";
              })
              config.nix-tun.services.traefik.entrypoints);

          api = {
            dashboard = true;
          };
        }
        (lib.mkIf config.nix-tun.services.traefik.enable_prometheus {
          metrics = {
            prometheus = {
              addEntryPointsLabels = true;
              addRoutersLabels = true;
              addServicesLabels = true;
              manualRouting = true;
            };
          };
        })
      ];
    };
  };
}
