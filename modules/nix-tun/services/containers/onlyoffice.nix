{ lib
, config
, inputs
, pkgs
, ...
}: {
  options.nix-tun.services.containers.onlyoffice = {
    enable = lib.mkEnableOption "setup authentik";
    hostname = lib.mkOption {
      type = lib.types.str;
    };
    jwtSecretFile = lib.mkOption {
      type = lib.types.path;
      description = "path to the sops secret file for jwt secret website Server";
    };
  };

  config =
    let
      opts = config.nix-tun.services.containers.onlyoffice;
    in
    lib.mkIf opts.enable {
      sops.secrets.onlyoffice_jwt = {
        sopsFile = opts.jwtSecretFile;
        format = "binary";
        mode = "444";
      };

      containers.onlyoffice = {
        bindMounts = {
          "secret" = {
            hostPath = config.sops.secrets.onlyoffice_jwt.path;
            mountPoint = config.sops.secrets.onlyoffice_jwt.path;
          };
        };

      };

      nix-tun.utils.containers.onlyoffice = {
        domains.onlyoffice = {
          port = 8000;
          domain = config.containers.onlyoffice.config.networking.hostName;
          healthcheck = "/";
        };

        config = { ... }: {
          nixpkgs.config.allowUnfree = true;
          services.onlyoffice = {
            enable = true;
            hostname = "https://${opts.hostname}";
            jwtSecretFile = config.sops.secrets.onlyoffice_jwt.path;
          };
        };
      };
    };
}
