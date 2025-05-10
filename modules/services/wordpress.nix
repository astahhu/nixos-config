{ config
, pkgs
, lib
, ...
}:
let

  instanceSettings =
    { lib
    , name
    , config
    , ...
    }: {
      options = {
        hostname = lib.mkOption {
          type = lib.types.str;
          description = ''
            The hostname of the Wordpress Site.
          '';
        };
      };
    };
in
{
  options.astahhu.wordpress = {
    enable = lib.mkEnableOption "Enable the wordpress Module";
    sites = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule instanceSettings);
      default = { };
      description = ''
        Specification of one more Wordpress Containers to Serve
      '';
    };
  };

  config = lib.mkIf config.astahhu.wordpress.enable {

    sops.secrets = lib.attrsets.mapAttrs'
      (name: value: {
        name = "wp-${name}-db-password";
        value = { };
      })
      config.astahhu.wordpress.sites;

    sops.templates =
      (lib.attrsets.mapAttrs'
        (name: value: {
          name = "wp-${name}.env";
          value = {
            content =
              let
                secret = config.sops.placeholder."wp-${name}-db-password";
              in
              ''
                WORDPRESS_DB_PASSWORD=${secret}
              '';
          };
        }
        )
        config.astahhu.wordpress.sites) //
      (lib.attrsets.mapAttrs'
        (name: value: {
          name = "wp-${name}-db.env";
          value = {
            content =
              let
                secret = config.sops.placeholder."wp-${name}-db-password";
              in
              ''
                MARIADB_PASSWORD=${secret}
              '';
          };
        }
        )
        config.astahhu.wordpress.sites);

    nix-tun.storage.persist.subvolumes =
      lib.attrsets.mapAttrs'
        (name: value: {
          name = "wp-${name}";
          value = {
            mode = "0755";
            directories = {
              wordpress = {
                mode = "0755";
              };
              mysql = {
                mode = "0700";
              };
            };
          };
        })
        config.astahhu.wordpress.sites;

    # Runtime
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };
    virtualisation.oci-containers.backend = "docker";

    # Containers
    virtualisation.oci-containers.containers =
      (lib.attrsets.mapAttrs'
        (name: value: {
          name = "wp-${name}-db";
          value = {
            image = "mariadb";
            environment = {
              "MYSQL_DATABASE" = "wp-${name}-db";
              "MYSQL_RANDOM_ROOT_PASSWORD" = "1";
              "MYSQL_USER" = "wp-${name}";
            };
            environmentFiles = [
              config.sops.templates."wp-${name}-db.env".path
            ];
            volumes = [
              "${config.nix-tun.storage.persist.path}/wp-${name}/mysql:/var/lib/mysql"
            ];
            log-driver = "journald";
            extraOptions = [
              "--network-alias=wp-${name}-db"
              "--network=wp_${name}_default"
            ];
          };
        })
        config.astahhu.wordpress.sites) //
      (lib.attrsets.mapAttrs'
        (name: value: {
          name = "wp-${name}";
          value = {
            image = "wordpress";
            environment = {
              "WORDPRESS_DB_HOST" = "wp-${name}-db";
              "WORDPRESS_DB_NAME" = "wp-${name}-db";
              "WORDPRESS_DB_USER" = "wp-${name}";
            };
            labels = {
              "traefik.enable" = "true";
              "traefik.http.routers.wp-${name}.entrypoints" = "websecure";
              "traefik.http.routers.wp-${name}.rule" = "Host(`${value.hostname}`) || Host(`www.${value.hostname}`)";
              "traefik.http.services.wp-${name}.loadbalancer.healthCheck.path" = "/";
              "traefik.http.routers.wp-${name}.priority" = "1";
              #"traefik.http.routers.wp-${name}.tls.certresolver" = "letsencrypt";
              "traefik.http.services.wp-${name}.loadbalancer.server.port" = "80";
            };
            environmentFiles = [
              config.sops.templates."wp-${name}.env".path
            ];
            volumes = [
              "${config.nix-tun.storage.persist.path}/wp-${name}/wordpress:/var/www/html"
            ];
            log-driver = "journald";
            extraOptions = [
              "--network-alias=wp-${name}"
              "--network=wp_${name}_default"
            ];
          };
        })
        config.astahhu.wordpress.sites);

    systemd.services =
      (lib.attrsets.mapAttrs'
        (name: value: {
          name = "docker-wp-${name}-db";
          value = {
            serviceConfig = {
              Restart = lib.mkOverride 500 "always";
              RestartMaxDelaySec = lib.mkOverride 500 "1m";
              RestartSec = lib.mkOverride 500 "100ms";
              RestartSteps = lib.mkOverride 500 9;
            };
            after = [
              "docker-network-wp_${name}_default.service"
            ];
            requires = [
              "docker-network-wp_${name}_default.service"
              "docker.service"
              "docker.socket"
            ];
            partOf = [
              "docker-compose-wp-${name}-root.target"
            ];
            wantedBy = [
              "docker-compose-wp-${name}-root.target"
            ];
          };
        })
        config.astahhu.wordpress.sites) // (lib.attrsets.mapAttrs'
        (name: value: {
          name = "docker-wp-${name}";
          value = {
            serviceConfig = {
              Restart = lib.mkOverride 500 "always";
              RestartMaxDelaySec = lib.mkOverride 500 "1m";
              RestartSec = lib.mkOverride 500 "100ms";
              RestartSteps = lib.mkOverride 500 9;
            };
            after = [
              "docker-network-wp_${name}_default.service"
            ];
            requires = [
              "docker-network-wp_${name}_default.service"
              "docker.service"
              "docker.socket"
            ];
            partOf = [
              "docker-compose-wp-${name}-root.target"
            ];
            wantedBy = [
              "docker-compose-wp-${name}-root.target"
            ];
          };
        })
        config.astahhu.wordpress.sites) // (lib.attrsets.mapAttrs'
        (name: value: {
          name = "docker-network-wp_${name}_default";
          value = {
            path = [ pkgs.docker ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStop = "docker network rm -f wp_${name}_default";
            };
            script = ''
              docker network inspect wp_${name}_default || docker network create wp_${name}_default
            '';
            partOf = [ "docker-compose-wp-${name}-root.target" ];
            wantedBy = [ "docker-compose-wp-${name}-root.target" ];
            requires = [
              "docker.service"
              "docker.socket"
            ];
          };
        })
        config.astahhu.wordpress.sites);

    systemd.targets = (lib.attrsets.mapAttrs'
      (name: value:
        {
          name = "docker-compose-wp-${name}-root";
          value = {
            unitConfig = {
              Description = "Root for ${name} Wordpress Docker containers";
            };
            wantedBy = [ "multi-user.target" ];
            requires = [
              "docker.service"
              "docker.socket"
            ];
            after = [
              "docker.service"
              "docker.socket"
            ];
          };
        })
      config.astahhu.wordpress.sites);

  };
}
