{ lib
, config
, pkgs
, inputs
, ...
}: {
  options.nix-tun.services.containers.nextcloud =
    let
      t = lib.types;
    in
    {
      enable = lib.mkEnableOption "setup nextcloud";
      hostname = lib.mkOption {
        type = t.str;
      };
      secretsFile = lib.mkOption {
        type = t.path;
        description = "path to the sops secret file for the adminPass";
      };
      extraApps = lib.mkOption {
        description = "nextcloud apps to install";
        type = t.listOf t.str;
        default = [ ];
      };
      extraTrustedProxies = lib.mkOption {
        type = t.listOf t.str;
        default = [ ];
      };
    };

  config =
    let
      opts = config.nix-tun.services.containers.nextcloud;
    in
    lib.mkIf opts.enable {
      nix-tun.utils.containers.spreed-signaling = {
        secrets = [
          "server-conf"
        ];

        domains.signaling = {
          domain = "signaling.${opts.hostname}";
          port = 8080;
        };

        config = { ... }: {
          systemd.services.spreed-signaling = {
            wantedBy = [ "multi-user.target" ];
            serviceConfig.LoadCredential = "config:/secret/server-conf";
            script =
              ''
                ${pkgs.nextcloud-spreed-signaling}/bin/server --config $CREDENTIALS_DIRECTORY/config
              '';
          };
        };
      };

      nix-tun.utils.containers.nextcloud = {
        secrets = [
          "admin-pass"
          "dbpass"
        ];
        domains.nextcloud = {
          domain = "${opts.hostname}";
          port = 80;
          healthcheck = "/";
        };

        volumes = {
          "/var/lib/mysql" = {
            owner = "mysql";
          };
          "/var/lib/nextcloud" = {
            owner = "nextcloud";
            group = "nextcloud";
            mode = "0755";
          };
        };
        config = { ... }: {
          environment.systemPackages = [
            pkgs.samba
          ];

          services.nextcloud = {
            enable = true;
            package = pkgs.nextcloud32;
            https = true;
            hostName = opts.hostname;
            phpExtraExtensions = all: [ all.pdlib all.smbclient ];
            notify_push.enable = true;

            database.createLocally = true;
            settings.trusted_proxies = [ "192.168.0.0/16" "172.16.0.0/12" "10.0.0.0/8" ] ++ opts.extraTrustedProxies;
            settings.trusted_domains = [ "nextcloud" opts.hostname ];
            config = {
              adminpassFile = "/secret/admin-pass";
              dbtype = "mysql";
            };

            phpOptions = {
              "opcache.jit" = "1255";
              "opcache.revalidate_freq" = "60";
              "opcache.interned_strings_buffer" = "16";
              "opcache.jit_buffer_size" = "128M";
              "apc.shm_size" = "512M";
            };

            extraApps = lib.attrsets.getAttrs opts.extraApps config.services.nextcloud.package.packages.apps;
            extraAppsEnable = true;

            configureRedis = true;
            caching.apcu = true;
            poolSettings = {
              pm = "dynamic";
              "pm.max_children" = "201";
              "pm.max_requests" = "500";
              "pm.max_spare_servers" = "150";
              "pm.min_spare_servers" = "50";
              "pm.start_servers" = "50";
            };
          };

          services.nginx.virtualHosts."${opts.hostname}" = {
            locations."^~ /push/".extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
            extraConfig = ''
              gzip_types text/javascript;
            '';
          };


          networking = {
            firewall = {
              enable = true;
              allowedTCPPorts = [ 80 ];
            };
          };

          system.stateVersion = "23.11";
        };
      };
    };
}
