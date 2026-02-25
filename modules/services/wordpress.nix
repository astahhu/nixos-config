{
  config,
  pkgs,
  lib,
  ...
}:

let
  instanceSettings =
    {
      lib,
      name,
      config,
      ...
    }:
    {
      options.hostname = lib.mkOption {
        type = lib.types.str;
        description = "The hostname of the Wordpress site.";
      };
    };
in
{
  options.astahhu.wordpress = {
    enable = lib.mkEnableOption "Enable the Wordpress module";

    sites = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule instanceSettings);
      default = { };
    };
  };

  config = lib.mkIf config.astahhu.wordpress.enable {

    ########################################
    # Secrets
    ########################################

    sops.secrets = lib.mapAttrs' (name: _: {
      name = "wp-${name}-db-password";
      value = { };
    }) config.astahhu.wordpress.sites;

    sops.templates =
      (lib.mapAttrs' (name: _: {
        name = "wp-${name}.env";
        value.content = ''
          WORDPRESS_DB_PASSWORD=${config.sops.placeholder."wp-${name}-db-password"}
        '';
      }) config.astahhu.wordpress.sites)
      // (lib.mapAttrs' (name: _: {
        name = "wp-${name}-db.env";
        value.content = ''
          MARIADB_PASSWORD=${config.sops.placeholder."wp-${name}-db-password"}
        '';
      }) config.astahhu.wordpress.sites);

    ########################################
    # ZFS Persistence (REPLACES subvolumes)
    ########################################

    nix-tun.storage.persist.datasets = lib.mapAttrs' (name: _: {
      name = "wp-${name}";
      value = {
        backup = true;
        path = "${config.nix-tun.storage.persist.path}/wp-${name}";

        directories = {
          wordpress = {
            owner = "33";
            group = "33";
            mode = "0755";
          };

          mysql = {
            owner = "999";
            group = "999";
            mode = "0700";
          };
        };
      };
    }) config.astahhu.wordpress.sites;

    ########################################
    # Docker
    ########################################

    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };

    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers =
      (lib.mapAttrs' (name: _: {
        name = "wp-${name}-db";
        value = {
          image = "mariadb";

          environment = {
            MYSQL_DATABASE = "wp-${name}-db";
            MYSQL_RANDOM_ROOT_PASSWORD = "1";
            MYSQL_USER = "wp-${name}";
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
      }) config.astahhu.wordpress.sites)
      // (lib.mapAttrs' (name: value: {
        name = "wp-${name}";
        value = {
          image = "wordpress";

          environment = {
            WORDPRESS_DB_HOST = "wp-${name}-db";
            WORDPRESS_DB_NAME = "wp-${name}-db";
            WORDPRESS_DB_USER = "wp-${name}";
          };

          labels = {
            "traefik.enable" = "true";
            "traefik.http.routers.wp-${name}.entrypoints" = "websecure";
            "traefik.http.routers.wp-${name}.rule" =
              "Host(`${value.hostname}`) || Host(`www.${value.hostname}`)";
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
      }) config.astahhu.wordpress.sites);
  };
}
