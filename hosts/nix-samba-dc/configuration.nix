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
  networking.hostName = "nix-samba-dc";

  # Uncomment if you need Secrets for this Hosts, AFTER the first install  
  # sops.defaultSopsFile = ../../secrets/nix-sample-server.yaml;

  services.bind = {
    enable = true;
    zones."ad.astahhu.de" = {
      master = true;
    };

    zones."154.99.134.in-addr.arpa" = {
      master = true;
    };

    extraConfig = ''
      include "${config.sops.bind-key.path}"
    '';
  };

  sops.secrets.bind-key = {
    sopsFile = ../../secrets/nix-samba-dc/bind_yaml;
    format = "binary";
  };

  sops.secrets.dhcp-ddns = {
    sopsFile = ../../secrets/nix-samba-dc/dhcp_ddcns_yaml;
    format = "binary";
  };

  nix-tun.storage.persist.subvolumes.kea = {
    owner = "kea";
  };

  services.kea = {
    dhcp4.enable = false;
    dhcp-ddns.configFile = config.sops.secrets.dhcp-ddns.path;

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


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.10"; # Did you read the comment?
}
