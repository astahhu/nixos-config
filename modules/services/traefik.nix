{
  config,
  pkgs,
  lib,
  ...
}: {
  options.astahhu.traefik = {
    enable = lib.mkEnableOption "Enable the Traefik Reverse Proxy";
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
    redirects =
      lib.mkOption {
      };
    services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({...}: {
        options = {
          router = {
            rule = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = ''
                The routing rule for this service. The rules are defined here: https://doc.traefik.io/traefik/routing/routers/
              '';
            };
            priority = lib.mkOption {
              type = lib.types.int;
              default = 0;
            };
            tls = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = ''
                  Enable tls for router, default = true;
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
              default = [];
              description = ''
                The middlewares applied to the router, the middlewares are applied in order.
              '';
            };
            entryPoints = lib.mkOption {
              type = lib.types.listOf (lib.types.str);
              default = ["websecure"];
              description = ''
                The Entrypoint of the service, default is 443 (websecure)
              '';
            };
          };
          servers = lib.mkOption {
            type = lib.types.listOf (lib.types.str);
            default = [];
            description = ''
              The hosts of the service
            '';
          };
        };
      }));
      default = {};
      description = ''
        A simple setup to configure http loadBalancer services and routers.
      '';
    };
  };

  config = lib.mkIf config.astahhu.traefik.enable {
    networking.firewall.allowedTCPPorts = [80 443];

    services.traefik = {
      enable = true;
      dynamicConfigOptions = {
        http = {
          routers =
            lib.attrsets.mapAttrs (
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
            config.astahhu.traefik.services;
          services =
            lib.attrsets.mapAttrs (name: value: {
              loadBalancer = {
                servers = builtins.map (value: {url = value;}) value.servers;
              };
            })
            config.astahhu.traefik.services;
        };
      };

      staticConfigOptions = {
        certificatesResolvers = {
          letsencrypt = {
            acme = {
              email = config.astahhu.traefik.letsencryptMail;
              storage = "/var/lib/traefik/acme.json";
              tlsChallenge = {};
            };
          };
        };

        entryPoints = {
          web = {
            address = ":80";
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
            address = ":443";
          };
        };

        api = {
          dashboard = true;
        };
      };
    };
  };
}
