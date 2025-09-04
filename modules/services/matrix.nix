{ lib
, config
, inputs
, pkgs
, ...
}: {
  options.astahhu.services.matrix = {
    enable = lib.mkEnableOption "setup matrix";
    servername = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Servername for matrix. The Matrix Host will be matrix.servername, except for .well-known files";
    };
  };
  config =
    let
      cfg = config.astahhu.services.matrix;
    in
    lib.mkIf cfg.enable {
      sops.secrets.matrix-client-secret = {
        mode = "444";
      };
      sops.secrets.postgresql-matrix-pw = {
        mode = "600";
      };

      sops.templates.matrix-pgpass = {
        mode = "600";
        uid = config.containers.matrix.config.users.users.matrix-synapse.uid;
        content = ''
          *:*:matrix:matrix:${config.sops.placeholder.postgresql-matrix-pw}
        '';
      };

      nix-tun.utils.containers."matrix" = {
        volumes = {
          "/var/lib/matrix-synapse" = { };
        };
        config =
          { lib
          , ...
          } @container: {
            # enable synapse
            services.matrix-synapse = {
              enable = true;
              settings = with container.config.services.coturn; {
                server_name = cfg.servername;
                database.args = {
                  database = "matrix";
                  user = "matrix";
                  passfile = config.sops.templates.matrix-pgpass.path;
                  host = "nix-postgresql.ad.astahhu.de";
                };
                oidc_providers = [
                  {
                    idp_id = "keycloak";
                    idp_name = "AStA Intern";
                    issuer = "https://keycloak.astahhu.de/realms/astaintern";
                    client_id = "synapse";
                    client_secret_file = config.sops.secrets.matrix-client-secrets.path;
                    scopes = [ "openid" "profile" ];
                    user_mapping_provider = {
                      config = {
                        localpart_template = "{{ user.preferred_username }}";
                        display_name_template = "{{ user.name }}";
                      };
                      backchannel_logout_enabled = true;
                    };
                  }
                ];
                serve_server_wellknown = true;
                public_baseurl = "https://matrix.${cfg.servername}:443";
                matrix_authentication_service = {
                  enabled = true;
                  secret_path = "someverysecuresecret";
                  endpoint = "http://localhost:8080";
                };
                #enable_registration = true;
                #enable_registration_without_verification = true;
                turn_uris = [ "turn:${realm}:3478?transport=udp" "turn:${realm}:3478?transport=tcp" ];
                turn_shared_secret = static-auth-secret-file;
                turn_user_lifetime = "1h";
                listeners = [
                  {
                    port = 8008;
                    bind_addresses = [ "0.0.0.0" ];
                    type = "http";
                    tls = false;
                    x_forwarded = true;
                    resources = [
                      {
                        names = [ "client" "federation" ];
                        compress = true;
                      }
                    ];
                  }
                ];
              };
            };
            # enable coturn
            services.coturn = {
              enable = true;
              no-cli = true;
              no-tcp-relay = true;
              min-port = 49000;
              max-port = 50000;
              use-auth-secret = true;
              static-auth-secret-file = "/run/secrets/matrix-pass";
              extraConfig = ''
                # for debugging
                verbose
                # ban private IP ranges
                no-multicast-peers
                denied-peer-ip=0.0.0.0-0.255.255.255
                denied-peer-ip=10.0.0.0-10.255.255.255
                denied-peer-ip=100.64.0.0-100.127.255.255
                denied-peer-ip=127.0.0.0-127.255.255.255
                denied-peer-ip=169.254.0.0-169.254.255.255
                denied-peer-ip=172.16.0.0-172.31.255.255
                denied-peer-ip=192.0.0.0-192.0.0.255
                denied-peer-ip=192.0.2.0-192.0.2.255
                denied-peer-ip=192.88.99.0-192.88.99.255
                denied-peer-ip=192.168.0.0-192.168.255.255
                denied-peer-ip=198.18.0.0-198.19.255.255
                denied-peer-ip=198.51.100.0-198.51.100.255
                denied-peer-ip=203.0.113.0-203.0.113.255
                denied-peer-ip=240.0.0.0-255.255.255.255
                denied-peer-ip=::1
                denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
                denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
                denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
                denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
                denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
                denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
                denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
              '';
            };
            # open the firewall
            networking.firewall =
              let
                range = with container.config.services.coturn;
                  lib.singleton
                    {
                      from = min-port;
                      to = max-port;
                    };
              in
              {
                allowedUDPPortRanges = range;
                allowedUDPPorts = [ 3478 5349 ];
                allowedTCPPortRanges = [ ];
                allowedTCPPorts = [ 80 443 8008 3478 5349 ];
              };
          };


      };

      nix-tun.services.traefik.services."{cfg.servername}" = {
        router = {
          rule = "Host(`matrix.${cfg.servername}`) || (Host(`${cfg.servername}`) && (Path(`/_matrix/{name:.*}`) || Path(`/_synapse/{name:.*}`) || Path(`/.well-known/matrix/server`) || Path(`/.well-known/matrix/client`)))";
          tls.enable = false;
        };
        servers = [ "http://${config.containers.matrix.config.networking.hostName}:8008" ];
      };

      containers."matrix" = {
        bindMounts = {
          "secret" = {
            hostPath = config.sops.secrets.matrix-client-secret.path;
            mountPoint = config.sops.secrets.matrix-client-secret.path;
          };
          "matrix-pgpass" = {
            hostPath = config.sops.templates.matrix-pgpass.path;
            mountPoint = config.sops.templates.matrix-pgpass.path;
          };

        };

      };
    };
}
