{ lib, pkgs, config, ... }: {
  options.astahhu.services.cinny = {
    enable = lib.mkEnableOption ''
      Enable the Cinny Matrix Client
    '';
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The url under which Cinny can be reached";
    };
    homeserver = lib.mkOption {
      type = lib.types.str;
      description = ''
        The url of the default Homeserver, which should be suggest.
      '';
    };
  };

  config = lib.mkIf config.astahhu.services.cinny.enable {
    nix-tun.services.traefik.services."cinny-cinny".router.tls.enable = false;
    nix-tun.utils.containers.cinny = {

      domains = {
        cinny = {
          domain = config.astahhu.services.cinny.domain;
          port = 80;
        };
      };
      config = { ... }: {
        services.caddy = {
          enable = true;
          extraConfig = let cinny = pkgs.cinny-unwrapped; in
            ''
              http://cinny.astahhu.de {
              	log {
              		output file /var/log/caddy/access-http:__cinny.astahhu.de.log
              	}

              	encode gzip
              	root *  ${cinny}
              }
            '';
        };
      };
    };

  };
}
