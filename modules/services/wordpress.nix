{ config, pkgs, lib, ... } : 
let
  instanceSettings = {lib, name, config, ...} :
  { 
    options = {
     baseDir = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = ''
	  The Direcotry where any Persistend Data for the Wordpress Container is Stored
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

  config = lib.mkIf (config.astahhu.wordpress.sites != {}) (lib.mkMerge [{
    containers.wp.config = {
      services.wordpress.sites."test.astahhu.de" = {
	plugins = {
	  inherit (pkgs.wordpressPackages.plugins)
          static-mail-sender-configurator;
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
  }]);

}
