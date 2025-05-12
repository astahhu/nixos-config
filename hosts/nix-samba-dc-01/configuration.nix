# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{ pkgs, config, lib, ... }: {
  astahhu.common = {
    is_server = true;
    is_qemuvm = true;
    disko = {
      enable = true;
      device = "/dev/sda";
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBKrYvYAQb5/k7q2WV67O1rdPYgwCbPIkI3mvAYsV7NE root@nix-samba-dc"
  ];

  astahhu.services.samba = {
    enable = true;
    workgroup = "AD.ASTAHHU";
    acme = {
      enable = true;
      email = "it@asta.hhu.de";
    };
    dc = {
      enable = true;
      primary = false;
      dhcp = {
        enable = true;
        subnet = "134.99.154.0/24";
        dns-servers = [
          "134.99.154.200"
          "134.99.154.201"
        ];
        time-servers = [
          "134.99.154.200"
          "134.99.154.201"
        ];
        routers = [
          "134.99.154.1"
        ];
        pool = "134.99.154.81 - 134.99.154.150";
      };
      dns = {
        dnssec-validation = "no";
        forwarders = [
          "134.99.154.226"
          "134.99.154.228"
        ];
      };
    };
  };


  sops.secrets.cloudflare-dns = {
    sopsFile = ../../secrets/nix-samba-dc/cloudflare-dns;
    format = "binary";
  };

  sops.defaultSopsKey = ../../secrets/nix-samba-dc.yaml;

  # Change for each System
  networking =
    {
      useDHCP = false;
      hostName = "nix-samba-dc-01";
      domain = "ad.astahhu.de";
      hosts = lib.mkForce {
        "127.0.0.1" = [ "localhost" ];
        "134.99.154.200" = [ "nix-samba-dc-01" "nix-samba-dc-01.ad.astahhu.de" ];
      };
    };

  systemd.network = {
    enable = true;
    networks."astahhu" = {
      name = "eth0";
      gateway = [
        "134.99.154.1"
      ];
      dns = [
        "127.0.0.1"
      ];
      address = [
        "134.99.154.200/24"
      ];
      ntp = [
        "134.99.128.80"
        "134.99.154.79"
      ];
      domains = [
        "ad.astahhu.de"
        "asta2012.local"
      ];
    };
  };
  # Uncomment if you need Secrets for this Hosts, AFTER the first install  
  # sops.defaultSopsFile = ../../secrets/nix-sample-server.yaml;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.10"; # Did you read the comment?
}
