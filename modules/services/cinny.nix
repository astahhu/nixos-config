{ lib, pkgs, config, ... }: {
  options.astahhu.services.cinny = {
    enable = lib.mkEnableOption ''
      Enable the Cinny Matrix Client
    '';
    url = lib.mkOption {
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
    nix-tun.utils.containers = {

      config = {
        domains = {
          cinny = {
            domain = config.astahhu.services.cinny.url;
            port = 80;
          };
        };
        services.caddy = {
          enable = true;
          virtualHosts."http://${config.astahhu.services.cinny.url}" =
            let cinny = pkgs.cinny-unwrapped; in
            {
              extraConfig = ''
                encode gzip
                root * ${cinny}
              '';
            };
        };
      };
    };

  };
}
