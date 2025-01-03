# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
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
  networking =
    {

      firewall = {
        enable = true;
        allowedUDPPorts = [ 53 ];
      };
      networkmanager.enable = true; # Easiest to use and most distros use this by default.
      defaultGateway = { address = "134.99.154.1"; interface = "eth0"; };
      useDHCP = false;
      hostName = "nix-samba-dc-01";
      domain = "ad.astahhu.de";
      interfaces = {
        eth0 = {
          ipv4 = {
            "addresses" = [
              {
                address = "134.99.154.200";
                prefixLength = 24;
              }
            ];
          };
        };
      };
    };
  # Uncomment if you need Secrets for this Hosts, AFTER the first install  
  # sops.defaultSopsFile = ../../secrets/nix-sample-server.yaml;

  astahhu.services.samba-dc = {
    enable = true;
    name = "NIX-SAMBA-DC-01";
  };

  services.bind = {
    enable = true;

    cacheNetworks = [
      "134.99.154.0/24"
      "127.0.0.0/8"
    ];

    ipv4Only = true;

    forwarders = [
      "134.99.154.226"
      "134.99.154.228"
    ];

    extraOptions = ''
      dnssec-validation no;
      tkey-gssapi-keytab "/var/lib/samba/bind-dns/dns.keytab";
      minimal-responses yes;
    '';

    extraConfig = ''
      include "/var/lib/samba/bind-dns/named.conf";
    '';

    #zones."ad.astahhu.de" = {
    #  master = true;
    #};

    #zones."154.99.134.in-addr.arpa" = {
    #  master = true;
    #};

    #extraConfig = ''
    #  include "${config.sops.secrets.bind-key.path}"
    #'';
  };

  #sops.secrets.bind-key = {
  #  sopsFile = ../../secrets/nix-samba-dc/bind_yaml;
  #  format = "binary";
  #};

  #sops.secrets.dhcp-ddns = {
  #  sopsFile = ../../secrets/nix-samba-dc/dhcp_ddcns_yaml;
  #  format = "binary";
  #};

  nix-tun.storage.persist.subvolumes.kea = {
    owner = "kea";
  };

  services.kea = {
    #dhcp-ddns.configFile = config.sops.secrets.dhcp-ddns.path;

    dhcp4 = {
      enable = false;
      settings = {
        valid-lifetime = 4000;
        renew-timer = 1000;
        rebind-timer = 2000;

        interfaces-config = {
          interfaces = [
            "eth0"
          ];
        };

        lease-database = {
          name = "/persist/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };

        subnet4 = [
          {
            pools = [
              {
                pool = "134.99.154.10 - 134.99.154.80";
              }
            ];
            subnet = "134.99.154.0/24";
            reservations = import ./dhcp.nix;
          }
        ];
      };
    };
  };

  # Networking

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
