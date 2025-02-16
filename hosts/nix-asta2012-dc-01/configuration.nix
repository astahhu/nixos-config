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

  systemd.timers.sync-sysvol = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "1m";
      Unit = "sync-sysvol.service'";
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG7K8KVbQFb805ZFHBScWi7YmG0hS26m4egNaZELwtMu root@nix-asta2012-dc"
  ];


  # Change for each System
  networking =
    {
      networkmanager.enable = true; # Easiest to use and most distros use this by default.
      timeServers = [
        "134.99.128.80"
        "134.99.128.79"
      ];
      defaultGateway = { address = "134.99.154.1"; interface = "eth0"; };
      useDHCP = false;
      hostName = "nix-asta2012dc1";
      domain = "asta2012.local";
      interfaces.eth0 = {
        ipv4 = {
          "addresses" = [
            {
              address = "134.99.154.228";
              prefixLength = 24;
            }
          ];
        };
      };
    };
  # Uncomment if you need Secrets for this Hosts, AFTER the first install  
  # sops.defaultSopsFile = ../../secrets/nix-sample-server.yaml;

  services.samba.settings = {
    intern = {
      "msdfs root" = "yes";
      "msdfs proxy" = "asta-fs-v-02.asta2012.local/intern";
      "browseable" = "yes";
    };
    public = {
      "msdfs root" = "yes";
      "msdfs proxy" = "asta-fs-v-02.asta2012.local/public";
      "browseable" = "yes";
    };
  };

  astahhu.services.samba = {
    enable = true;
    workgroup = "ASTA2012";
    dc = {
      enable = true;
      primary = false;
      dns = {
        dnssec-validation = "no";
        forwarders = [
          "134.99.128.2"
          "134.99.128.5"
        ];
      };
    };
  };

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
