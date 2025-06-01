# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{ pkgs
, config
, modulesPath
, ...
}: {

  # Change for each System
  astahhu.common.is_lxc = true;

  # Uncomment if you need Secrets for this Hosts, AFTER the first install
  sops.defaultSopsFile = ../../secrets/nix-wireguard.yaml;
  sops.secrets.headscale-oauth-client-secret = {
    owner = "headscale";
  };
  sops.secrets.tailscale-api-key = { };
  sops.secrets.wireguard_private = {
    owner = "systemd-network";
  };
  networking = {
    hostName = "nix-wireguard";
    interfaces.eth0.ipv4 = {
      addresses = [
        {
          address = "134.99.154.242";
          prefixLength = 24;
        }
      ];
    };
    nat = {
      enable = true;
      externalInterface = "eth0";
      internalInterfaces = [ "wg0" ];
      internalIPs = [
        "10.105.42.1/24"
      ];
    };
    firewall = {
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ 51820 ];
    };
    domain = "ad.astahhu.de";
    nameservers = [ "134.99.154.200" "134.99.154.201" ];
    defaultGateway = { address = "134.99.154.1"; interface = "eth0"; };
  };


  services.resolved = {
    enable = true;
    fallbackDns = [ ];
  };

  systemd.network = {
    enable = true;
    networks = {
      # "wg0" is the network interface name. You can name the interface arbitrarily.
      wg0 = {
        matchConfig.Name = "wg0";
        address = [ "10.105.42.1/24" ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv4Forwarding = true;
        };
      };
    };

    netdevs = {
      "wg-50" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };


        wireguardConfig = {
          PrivateKeyFile = "${config.sops.secrets.wireguard_private.path}";
          ListenPort = 51820;
        };

        wireguardPeers = [
          # List of allowed peers.
          {
            # 2
            PublicKey = "qAzWfOAMP3w4vusIyjyHFl7aTLG7eZrCz20bE6PkVik=";
            AllowedIPs = [ "10.105.42.2/32" ];
          }
          {
            # 3
            PublicKey = "X7SwpnOfNBFyXo5ELD7Jfd4psSu/WiF6ucyNP+zvrww=";
            AllowedIPs = [ "10.105.42.3/32" ];
          }
          {
            # Petra's Laptop
            PublicKey = "/+DAqTxrCYqicFmJ3hGPc4++BwBbkni7MH5BNOKuinc=";
            AllowedIPs = [ "10.105.42.4/32" ];
          }
          {
            # 5
            PublicKey = "Xt92xMbkfhiB63Yig3caZuPs7geA53LdCwFwCZjR/y0=";
            AllowedIPs = [ "10.105.42.5/32" ];
            Endpoint = "134.99.39.12:60538";
          }
          {
            # 6
            PublicKey = "Cxjqdj+sbnz1reh0INfylzyhkm18zjWgg3P6BOC+DW0=";
            AllowedIPs = [ "10.105.42.6/32" ];
          }
          {
            # 7
            PublicKey = "uOKm/Gdqn7dGMYlzYuVB9LP2U2peLP6qqHP8neUNwEU=";
            AllowedIPs = [ "10.105.42.7/32" ];
          }
          {
            # 8
            PublicKey = "zsqHwvlfiPVuPMVKoIeN1h0CE5ts9H/numnOIrNJZlk=";
            AllowedIPs = [ "10.105.42.8/32" ];
          }
          {
            # 9
            PublicKey = "1FmBk72xRgoFxSBaeaxeHWBzlk+mKFAUzDnUUiGpKUo=";
            AllowedIPs = [ "10.105.42.9/32" ];
          }
          {
            # 10
            PublicKey = "KdimHNVz4OmMlc+ZUz06ntBLdB6fw+lC4RmdWXDt00U=";
            AllowedIPs = [ "10.105.42.10/32" ];
          }
          {
            # 11
            PublicKey = "t0hmDrrymNCcmkcaBpfEUWUBdJ2sOdexHFjwbJzIMHo=";
            AllowedIPs = [ "10.105.42.11/32" ];
          }
          {
            # 12
            PublicKey = "mLZAKxex044RCUbIAiOC8LdlHyYvp+CVeciHRLZLDgE=";
            AllowedIPs = [ "10.105.42.12/32" ];
          }
          {
            # 13
            PublicKey = "hC4d0h2ewwWFdHeKBRGJupR1Qm1pSv832rkv8K4xpgA=";
            AllowedIPs = [ "10.105.42.13/32" ];
          }
          {
            # 14
            PublicKey = "4OV6hnXsTDdmF0hj0IyAyPg9fwJAOhqHEv04A9ZiFlQ=";
            AllowedIPs = [ "10.105.42.14/32" ];
          }
          {
            # 15
            PublicKey = "LOJoxvbNiRZ3/EAd10kPolzcGb2VeMf1lAVTeiMriyU=";
            AllowedIPs = [ "10.105.42.15/32" ];
          }
          {
            # 16
            PublicKey = "TTWhoxuCOJryuTfMcQ+7mWxpbYtOngfyqbK0LCF+qE0=";
            AllowedIPs = [ "10.105.42.16/32" ];
          }
          {
            # 17
            PublicKey = "GMzQnVABjufZQ6Czm6D+X85C5qr9Y2FYF3fWMg313QM=";
            AllowedIPs = [ "10.105.42.17/32" ];
          }
          {
            # 18
            PublicKey = "zZIOUcr6TTISKLSe0RzFpWyghKGD0PTsr5WlcRBl3xQ=";
            AllowedIPs = [ "10.105.42.18/32" ];
          }
          {
            # 19
            PublicKey = "mNeA/lJCOVO78BxPiXhwbBjLAZwQ90NNMPDdf1Z3v24=";
            AllowedIPs = [ "10.105.42.19/32" ];
          }
          {
            # 20
            PublicKey = "nJBfaylAfoTZjYco5ZgJusm60XOBCKzFeK30yY3e41k=";
            AllowedIPs = [ "10.105.42.20/32" ];
          }
          {
            # 21
            PublicKey = "/hTh57oidbhGEWViahL4dxhCLxXQ/q0I8MIlZ7go/1E=";
            AllowedIPs = [ "10.105.42.21/32" ];
          }
          {
            # 22
            PublicKey = "2ytpT/rSMOv0xpukKm5BL1ipDyv9MG8wqwxLG0790yE=";
            AllowedIPs = [ "10.105.42.22/32" ];
          }
          {
            # 23
            PublicKey = "L235h97SbeoYKE25VzkJp7uilmQ3VJzGLZrr3SKbIHg=";
            AllowedIPs = [ "10.105.42.23/32" ];
          }
          {
            # 24
            PublicKey = "ri3E91KHp15VrgdVSdHBQimb97DEQuDu8SiQ3SODB1I=";
            AllowedIPs = [ "10.105.42.24/32" ];
          }
          {
            # 25
            PublicKey = "UPVDVIBvxODZLA/RTHt5sWRXBW9vdP8aXoHHR4LH6w4=";
            AllowedIPs = [ "10.105.42.25/32" ];
          }
          {
            # vorstand-05
            PublicKey = "LMtCs1tQDvYGTA/juT+6vPjaYJ7a+SXx+gQ2OFxYIW4=";
            AllowedIPs = [ "10.105.42.26/32" ];
          }
          {
            # sotirislaptop
            PublicKey = "epOFx7BPGQ1ZbN2aX90ARKp8+qi4Z4JhXy+fOqClo34=";
            AllowedIPs = [ "10.105.42.27/32" ];
          }
          {
            # sotirisdesktop
            PublicKey = "HHlyGpKT07fHtBv3ggVhYzkcHfoA18Kty99GdddgX1Y=";
            AllowedIPs = [ "10.105.42.28/32" ];
          }
          {
            # sotiristablet
            PublicKey = "Pwp6d3ZznOss6Rz6JLly6deJymh7NDT9N0a9B0YJKRU=";
            AllowedIPs = [ "10.105.42.29/32" ];
          }
        ];
      };
    };
  };



  users.users.headscale.uid = 666;
  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 8080;
    settings = {
      server_url = "https://vpn.astahhu.de";
      #policy.path = builtins.toFile "policy.json" (builtins.toJSON {
      #  "acls" = [ ];
      #  "groups" = { };
      #  "hosts" = { };
      #  "tagOwners" = {
      #    "tag:router" = [
      #    ];
      #  };
      #  "autoApprovers" = {
      #    "routes" = {
      #      "134.99.0.0/16" = [ "tag:router" ];
      #      "10.105.41.0/24" = [ "tag:router" ];
      #    };
      #  };
      #});
      dns = {
        magic_dns = true;
        nameservers.split = {
          "ad.astahhu.de" = [
            "134.99.154.200"
            "134.99.154.201"
          ];
          "asta2012.local" = [
             134.99.154.226
             134.99.154.228
           ];
        };
        search_domains = [
          "ad.astahhu.de"
          "asta2012.local"
        ];
        base_domain = "tailnet.astahhu.de";
      };
      oidc = {
        issuer = "https://keycloak.astahhu.de/realms/astaintern";
        client_secret_path = config.sops.secrets.headscale-oauth-client-secret.path;
        client_id = "headscale";
        scope = [
          "openid"
          "profile"
          "email"
          "offline_access"
        ];
      };
    };
  };

  systemd.services.tailscaled.requires = [ "headscale.service" ];

  services.tailscale = {
    enable = true;
    disableTaildrop = true;
    useRoutingFeatures = "both";
    authKeyFile = config.sops.secrets.tailscale-api-key.path;
    interfaceName = "userspace-networking";
    authKeyParameters = {
      preauthorized = true;
    };
    extraUpFlags = [
      "--login-server=https://vpn.astahhu.de"
      "--advertise-tags=router"
      "--advertise-routes=134.99.154.0/24,10.105.41.0/24"
    ];
    extraSetFlags = [
      "--login-server=https://vpn.astahhu.de"
      "--advertise-routes=134.99.154.0/24,10.105.41.0/24"
    ];
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.10"; # Did you read the comment?

}
