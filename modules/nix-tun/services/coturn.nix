{ lib
, config
, inputs
, pkgs
, ...
}: {
  options.nix-tun.services.coturn = {
    enable = lib.mkEnableOption "Setup coturn";
  };
  config =
    let
      opts = config.nix-tun.services.coturn;
    in
    lib.mkIf opts.enable {
      nix-tun.utils.containers."coturn" = {
        exposedPorts = lib.mkMerge [
          (lib.lists.map
            (item:
              {
                port = item;
                hostPort = item;
                protocol = "udp";
              })
            (lib.lists.range 49000 50000))
          [
            {
              port = 3478;
              hostPort = 3478;
              protocol = "udp";
            }
            {
              port = 5349;
              hostPort = 5349;
              protocol = "udp";
            }
            {
              port = 3478;
              hostPort = 3478;
              protocol = "tcp";
            }
            {
              port = 5349;
              hostPort = 5349;
              protocol = "tcp";
            }
          ]
        ];
        secrets = [
          "auth-secret"
        ];
        config =
          { config
          , lib
          , ...
          }: {
            systemd.services.coturn.serviceConfig.LoadCredential = "auth-secret:/secret/auth-secret";
            # enable coturn
            services.coturn = {
              enable = true;
              no-cli = true;
              no-tcp-relay = true;
              min-port = 49000;
              max-port = 50000;
              use-auth-secret = true;
              static-auth-secret-file = "$CREDENTIALS_DIRECTORY/auth-secret";
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
            system.stateVersion = "23.11";
          };
      };
    };
}
