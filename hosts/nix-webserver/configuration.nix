{ inputs, pkgs, config, ... }: {
  astahhu.common = {
    is_server = true;
    is_qemuvm = true;
    disko = {
      enable = true;
      device = "/dev/sda";
    };
  };


  # Change for each System
  networking.hostName = "nix-webserver";
  networking.domain = "ad.astahhu.de";
  networking.useDHCP = false;

  # Uncomment if you need Secrets for this Hosts, AFTER the first install  
  sops.defaultSopsFile = ../../secrets/nix-webserver.yaml;

  systemd.network = {
    enable = true;
    networks."astahhu" = {
      name = "ens18";
      gateway = [
        "134.99.154.1"
      ];
      dns = [
        "134.99.154.200"
        "134.99.154.201"
      ];
      address = [
        "134.99.154.51/24"
      ];
      ntp = [
        "134.99.154.200"
        "134.99.154.201"
      ];
      domains = [
        "ad.astahhu.de"
        "asta2012.local"
      ];
    };
  };

  services.resolved = {
    enable = true;
    fallbackDns = [ ];
  };



  # Networking
  networking.firewall.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };


  nix-tun.services.traefik = {
    enable_docker = true;
  };

  services.traefik.staticConfigOptions.entryPoints.websecure = {
    forwardedHeaders.insecure = true; #trustedIPs = [ "134.99.154.48" ];
    proxyProtocol.insecure = true; #trustedIPs = [ "134.99.154.48" ];
  };

  astahhu.services.calendar-join = {
    enable = true;
    calendars = {
      fachschaften = {
        "FS Physik" = "https://nextcloud.inphima.de/remote.php/dav/public-calendars/6tsADsaDtDHesoXa?export";
        "FS Info" = "https://nextcloud.inphima.de/remote.php/dav/public-calendars/CAx5MEp7cGrQ6cEe?export";
      };
    };
  };

  nix-tun.services.grafana = {
    enable = true;
    oauth = {
      enabled = true;
      name = "AStA Intern";
      allow_sign_up = true;
      client_id = "grafana";
      scopes = "openid email profile offline_access roles";
      email_attribute_path = "email";
      login_attribute_path = "username";
      name_attribute_path = "full_name";
      auth_url = "https://keycloak.astahhu.de/realms/astaintern/protocol/openid-connect/auth";
      token_url = "https://keycloak.astahhu.de/realms/astaintern/protocol/openid-connect/token";
      api_url = "https://keycloak.astahhu.de/realms/astaintern/protocol/openid-connect/userinfo";
      role_attribute_path = "contains(roles[*], 'Admin') && 'Admin' || contains(roles[*], 'Editor') && 'Editor' || 'Viewer'";
    };
    domain = "grafana.astahhu.de";
    prometheus = {
      nixosConfigs = inputs.self.nixosConfigurations;
      domain = "prometheus.astahhu.de";
    };
  };

  astahhu.services.vaultwarden = {
    enable = true;
    domain = "vaultwarden.astahhu.de";
  };

  astahhu.wordpress = {
    enable = true;
    sites = {
      astahhu = {
        hostname = "astahhu.de";
      };
      fsref = {
        hostname = "fsref.astahhu.de";
      };
      sp = {
        hostname = "sphhu.de";
      };
      finanzen = {
        hostname = "finanzen.astahhu.de";
      };
      verleih = {
        hostname = "verleih.astahhu.de";
      };
      esaghhu = {
        hostname = "esaghhu.de";
      };
      fsbio = {
        hostname = "fsbio.astahhu.de";
      };
      tinby = {
        hostname = "tinby.astahhu.de";
      };
      femref = {
        hostname = "femref.astahhu.de";
      };
      fssowi = {
        hostname = "fssowi.astahhu.de";
      };
      itref = {
        hostname = "it.astahhu.de";
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.10"; # Did you read the comment?
}
