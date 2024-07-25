{
  config,
  pkgs,
  lib,
  ...
}: let
  instanceSettings = {
    lib,
    name,
    config,
    ...
  }: {
    options = {
      baseDir = lib.mkOption {
        type = lib.types.str;
        default = "wordpress/${builtins.replaceStrings ["."] ["-"] name}";
        description = ''
          The Directory where any Persistent Data for the Wordpress Container is Stored
        '';
      };
    };
  };
in {
  options.astahhu.wordpress = {
    sites = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule instanceSettings);
      default = {};
      description = ''
        Specification of one more Wordpress Containers to Serve
      '';
    };
  };

  config = {
    astahhu.impermanence.persistentSubvolumes =
      lib.attrsets.mapAttrs' (name: value: {
        name = value.baseDir;
        value = {
          mode = "0755";
	  directories = {
	    wordpress = {
	      mode = "0755";
	      group = "root";
	      owner = "root";
	    };
	    mysql = {
	      mode = "0700";
	      owner = builtins.toString config.containers."${builtins.replaceStrings ["."] ["-"] ("wp-" + name)}".config.users.users.mysql.uid;
	      group = builtins.toString config.containers."${builtins.replaceStrings ["."] ["-"] ("wp-" + name)}".config.users.groups.mysql.gid;
	    };
	  };
        };
      })
      config.astahhu.wordpress.sites;
    astahhu.traefik.services = lib.attrsets.mapAttrs' (name: value:
      lib.attrsets.nameValuePair (builtins.replaceStrings ["."] ["-"] ("wp-" + name))
      {
        router.rule = "Host(`${name}`) || Host(`www.${name}`)";
        router.tls.enable = false;
        servers = [
          "http://${builtins.replaceStrings ["."] ["-"] ("wp-" + name)}"
        ];
      })
    config.astahhu.wordpress.sites;

    containers = lib.attrsets.mapAttrs' (name: value:
      lib.attrsets.nameValuePair (builtins.replaceStrings ["."] ["-"] ("wp-" + name))
      {
        autoStart = true;
        bindMounts.persistent = {
          hostPath = "${config.astahhu.impermanence.defaultPath}/${value.baseDir}";
          mountPoint = "/persist";
	  isReadOnly = false;
        };
        bindMounts.wordpress = {
          hostPath = "${config.astahhu.impermanence.defaultPath}/${value.baseDir}/wordpress";
          mountPoint = "/var/lib/wordpress";
	  isReadOnly = false;
        };
        bindMounts.mysql = {
          hostPath = "${config.astahhu.impermanence.defaultPath}/${value.baseDir}/mysql";
          mountPoint = "/var/lib/mysql";
	  isReadOnly = false;
        };
        privateNetwork = true;
        ephemeral = true;
        hostAddress = "192.168.100.10";
        localAddress = "192.168.100.11";

        config = {pkgs, ...}: {
          networking.firewall.allowedTCPPorts = [80];
          services.wordpress.sites."${name}" = {
            plugins = {
              inherit
                (pkgs.wordpressPackages.plugins)
                static-mail-sender-configurator
                ;
            };

            languages = [
              pkgs.wordpressPackages.languages.de_DE
            ];

            settings = {
              WP_DEBUG = true;
              WPLANG = "de_DE";
              ## Mail settings
              WP_MAIL_FROM = "noreply@asta.hhu.de";
              FORCE_SSL_ADMIN = true;
            };

            extraConfig = ''
              $_SERVER['HTTPS']='on';
            '';
          };
        };
      }) config.astahhu.wordpress.sites;
  };
}
