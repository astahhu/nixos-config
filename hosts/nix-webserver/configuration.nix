{ pkgs, config, ... }: {
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

  astahhu.services.grafana = {
    enable = true;
    domain = "grafana.astahhu.de";
    prometheus.domain = "prometheus.astahhu.de";
  };

  astahhu.common.enable-node-exporter = true;

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
