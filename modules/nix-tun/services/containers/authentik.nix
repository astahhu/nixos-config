{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: {
  options.nix-tun.services.containers.authentik = {
    enable = lib.mkEnableOption "setup authentik";
    hostname = lib.mkOption {
      type = lib.types.str;
    };
    mail = {
        host = lib.mkOption {
	  type = lib.types.str;
	};
	port = lib.mkOption {
	  type = lib.types.int;
	};
	username = lib.mkOption {
	  type = lib.types.str;
	};
	from = lib.mkOption {
	  type = lib.types.str;
	};
    };
    envFile = lib.mkOption {
      type = lib.types.path;
      description = "path to the sops secret file for the fscshhude website Server";
    };
  };

  config = let
    opts = config.nix-tun.services.containers.authentik;
  in
    lib.mkIf opts.enable {
      sops.secrets.authentik_env = {
        sopsFile = opts.envFile;
        format = "binary";
        mode = "444";
      };

      nix-tun.utils.containers."authentik".volumes = {
        "/var/lib/postgresql" = {
          owner = "postgres";
        };
      };

      nix-tun.services.traefik.services."authentik" = {
        router.rule = "Host(`${opts.hostname}`)";
        servers = ["http://${config.containers.authentik.config.networking.hostName}"];
      };

      containers.authentik = {
        ephemeral = true;
        autoStart = true;
        privateNetwork = true;
        hostAddress = "192.168.111.10";
        localAddress = "192.168.111.11";

        bindMounts = {
          "secret" = {
            hostPath = config.sops.secrets.authentik_env.path;
            mountPoint = config.sops.secrets.authentik_env.path;
          };
        };

        config = {...}: {
          imports = [
            inputs.authentik-nix.nixosModules.default
          ];

          networking.hostName = "authentik";

          services.authentik = {
            enable = true;
            environmentFile = config.sops.secrets.authentik_env.path;
            createDatabase = true;

            settings = {
              email = {
                host = opts.mail.host;
                port = opts.mail.port;
                username = opts.mail.username;
                use_tls = true;
                use_ssl = false;
                from = opts.mail.from;
              };
              disable_startup_analytics = true;
              avatars = "initials";
            };

            nginx = {
              enable = true;
              enableACME = false;
              host = "localhost";
            };
          };

          networking = {
            firewall = {
              enable = true;
              allowedTCPPorts = [80 9443];
            };
            # Use systemd-resolved inside the container
            # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
            useHostResolvConf = lib.mkForce false;
          };

          services.resolved.enable = true;

          system.stateVersion = "23.11";
        };
      };
    };
}
