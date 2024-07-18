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
        default = "";
        description = ''
          The Directory where any Persistend Data for the Wordpress Container is Stored
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
        privateNetwork = true;
        hostAddress = "192.168.100.10";
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
      })
    config.astahhu.wordpress.sites;
  };
}
