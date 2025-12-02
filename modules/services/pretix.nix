{ pkgs, config, lib, ... }: {
  options.astahhu.services.pretix = {
    enable = lib.mkEnableOption "pretix";
    hostname = lib.mkOption {
      description = "pretix";
      type = lib.types.str;
    };
    email = lib.mkOption {
      description = "from email address";
      type = lib.types.str;
    };
  };

  config = lib.mkIf config.astahhu.services.pretix.enable {
    nix-tun.services.traefik.services.pretix-pretix.router.tls.enable = false;

    nix-tun.utils.containers.pretix = {
      secrets = [
        "env"
      ];
      volumes = { };
      domains = {
        pretix = {
          domain = config.astahhu.services.pretix.hostname;
          port = 80;
        };
      };

      config = { ... }: {
        boot.isContainer = true;
        services.pretix = {
          enable = true;
          environmentFile = "/secret/env";
          database.createLocally = false;
          nginx.domain = config.astahhu.services.pretix.hostname;
          settings = {
            mail.from = "${config.astahhu.services.pretix.email}";
            pretix = {
              instance_name = config.astahhu.services.pretix.hostname;
              url = "https://${config.astahhu.services.pretix.hostname}";
            };
            database = {
              host = "nix-postgresql.ad.astahhu.de";
            };
          };
          plugins = with config.services.pretix.package.plugins; [
            pretix-oppwa
            pretix-pages
            pretix-passbook
            pretix-sepadebit
            pretix-servicefees
            pretix-sofort
            pretix-taler
            pretix-venueless
            pretix-zugferd
            pretix-batch-emailer
            pretix-question-placeholders
            prtx-faq
            pretix-limit-phone-country
            pretix-mandatory-product
            pretix-manualseats
            pretix-oidc
            pretix-automated-orders
            pretix-roomsharing
            pretix-sumup-payment
            pretix-dbevent
            pretix-fontpack-free
          ];
        };
      };
    };
  };
}
