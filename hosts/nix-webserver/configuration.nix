{ pkgs, ... }: {
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

  # Uncomment if you need Secrets for this Hosts, AFTER the first install  
  sops.defaultSopsFile = ../../secrets/nix-webserver.yaml;

  # Networking
  networking.firewall.enable = true;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };

  services.grafana = {
    enable = true;
    settings.server.protocol = "socket";
    settings.server.root_url = "https://grafana.astahhu.de";
    settings.server.domain = "grafana.astahhu.de";
  };

  nix-tun.services.traefik.services.grafana = {
    servers = [
      "unix://run/grafana/grafana.sock"
    ];
    router.rule = "Host(`grafana.astahhu.de`)";
    router.tls.enable = false;
  };


  nix-tun.services.traefik = {
    enable = true;
    letsencryptMail = "it@asta.hhu.de";
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
