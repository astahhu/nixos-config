{ inputs, pkgs, config, ... }: {
  astahhu.common = {
    is_server = true;
    is_lxc = true;
    uses_btrfs = true;
  };


  # Change for each System
  networking.hostName = "nix-postgresql";
  networking.domain = "ad.astahhu.de";
  networking.useDHCP = false;

  # Uncomment if you need Secrets for this Hosts, AFTER the first install  
  sops.defaultSopsFile = ../../secrets/nix-postgresql.yaml;

  systemd.network = {
    enable = true;
    networks."astahhu" = {
      name = "eth0";
      gateway = [
        "134.99.154.1"
      ];
      dns = [
        "134.99.154.200"
        "134.99.154.201"
      ];
      address = [
        "134.99.154.212/24"
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


  services.traefik.staticConfigOptions.entryPoints.websecure = {
    forwardedHeaders.insecure = true; #trustedIPs = [ "134.99.154.48" ];
    proxyProtocol.insecure = true; #trustedIPs = [ "134.99.154.48" ];
  };

  astahhu.services.postgres = {
    enable = true;
    acme = {
      enable = true;
      email = "it@astahhu.de";
    };
    databases = [
      "matrix"
      "nextcloud"
      "keycloak"
      "vaultwarden"
      "pretix"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
