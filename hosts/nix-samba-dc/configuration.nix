# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  pkgs,
  config,
  lib,
  ...
}:
{

  astahhu.common = {
    is_server = true;
    uses_btrfs = true;
    is_lxc = true;
  };

  nix-tun.alloy.prometheus-host = "";
  environment.etc."alloy/traefik-metrics.alloy".text = "";

  systemd.timers.sync-sysvol = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "1m";
      Unit = "sync-sysvol.service'";
    };
  };

  systemd.services.sync-sysvol = {
    path = [
      pkgs.openssh
    ];
    script = ''
      ${pkgs.rsync}/bin/rsync -XAavz --delete-after /var/lib/samba/sysvol/ nix-samba-dc-01.ad.astahhu.de:/var/lib/samba/sysvol/ -e "ssh -i /root/.ssh/sync"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.sync-idmap = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "3h";
      Unit = "sync-idmap.service'";
    };
  };

  systemd.services.sync-idmap = {
    script = ''
      ${pkgs.tdb}/bin/tdbbackup -s .bak /var/lib/samba/private/idmap.ldb
      ${pkgs.rsync}/bin/rsync -XAavz --delete-after /var/lib/samba/private/idmap.ldb.bak nix-samba-dc-01.ad.astahhu.de:/var/lib/samba/private/idmap.ldb -e "${pkgs.openssh}/bin/ssh -i /root/.ssh/sync"
      ${pkgs.openssh}/bin/ssh -i /root/.ssh/sync nix-samba-dc-01.ad.astahhu.de net cache flush
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  # Change for each System
  networking = {
    useDHCP = false;
    hostName = "nix-samba-dc";
    domain = "ad.astahhu.de";
    hosts = lib.mkForce {
      "127.0.0.1" = [ "localhost" ];
      "134.99.154.201" = [
        "nix-samba-dc"
        "nix-samba-dc.ad.astahhu.de"
      ];
    };
  };

  services.resolved = {
    enable = true;
    fallbackDns = [ "127.0.0.1" ];
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
        "134.99.154.201/24"
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

  astahhu.services.samba = {
    enable = true;
    workgroup = "AD.ASTAHHU";
    server_address = "134.99.154.201";
    acme = {
      enable = true;
      email = "it@asta.hhu.de";
    };
    dc = {
      enable = true;
      primary = true;
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
        pool = "134.99.154.10 - 134.99.154.80";
      };
      domain-dfs = {
        "intern" = {
          "Intern AntiFaRaDis" = "nix-samba-fs.ad.astahhu.de/Intern AntiFaRaDis";
          "Intern Autonom" = "nix-samba-fs.ad.astahhu.de/Intern Autonom";
          "Intern Barriereref" = "nix-samba-fs.ad.astahhu.de/Intern Barriereref";
          "Intern BiSchwu" = "nix-samba-fs.ad.astahhu.de/Intern BiSchwu";
          "Intern Buchhaltung" = "nix-samba-fs.ad.astahhu.de/Intern Buchhaltung";
          "Intern Deutschkurse" = "nix-samba-fs.ad.astahhu.de/Intern Deutschkurse";
          "Intern Fachschaftsref" = "nix-samba-fs.ad.astahhu.de/Intern Fachschaftsref";
          "Intern Finanzref" = "nix-samba-fs.ad.astahhu.de/Intern Finanzref";
          "Intern Flüchtlingsarbeit" = "nix-samba-fs.ad.astahhu.de/Intern Flüchtlingsarbeit";
          "Intern Frauenref" = "nix-samba-fs.ad.astahhu.de/Intern Frauenref";
          "Intern HoPoref" = "nix-samba-fs.ad.astahhu.de/Intern HoPoref";
          "Intern Internationalesref" = "nix-samba-fs.ad.astahhu.de/Intern Internationalesref";
          "Intern ITref" = "nix-samba-fs.ad.astahhu.de/Intern ITref";
          "Intern Kulturref" = "nix-samba-fs.ad.astahhu.de/Intern Kulturref";
          "Intern Kommref" = "nix-samba-fs.ad.astahhu.de/Intern Kommref";
          "Intern LesBiref" = "nix-samba-fs.ad.astahhu.de/Intern LesBiref";
          "Intern Material" = "nix-samba-fs.ad.astahhu.de/Intern Material";
          "Intern Materialbeauftragter" = "nix-samba-fs.ad.astahhu.de/Intern Materialbeauftragter";
          "Intern Mieterverein" = "nix-samba-fs.ad.astahhu.de/Intern Mieterverein";
          "Intern Oekoref" = "nix-samba-fs.ad.astahhu.de/Intern Oekoref";
          "Intern Presseref" = "nix-samba-fs.ad.astahhu.de/Intern Presseref";
          "Intern Rechtsberatung" = "nix-samba-fs.ad.astahhu.de/Intern Rechtsberatung";
          "Intern Sekretariat Finanz Buchhaltung" =
            "nix-samba-fs.ad.astahhu.de/Intern Sekretariat Finanz Buchhaltung";
          "Intern Sozialref" = "nix-samba-fs.ad.astahhu.de/Intern Sozialref";
          "Intern SP" = "nix-samba-fs.ad.astahhu.de/Intern SP";
          "Intern Steuern" = "nix-samba-fs.ad.astahhu.de/Intern Steuern";
          "Intern Teamassistenz" = "nix-samba-fs.ad.astahhu.de/Intern Teamassistenz";
          "Intern Vorstand" = "nix-samba-fs.ad.astahhu.de/Intern Vorstand";
        };
        "public" = {
          "Public AntiFaRaDis" = "nix-samba-fs.ad.astahhu.de/Public AntiFaRaDis";
          "Public Autonom" = "nix-samba-fs.ad.astahhu.de/Public Autonom";
          "Public Barriereref" = "nix-samba-fs.ad.astahhu.de/Public Barriereref";
          "Public BiSchwu" = "nix-samba-fs.ad.astahhu.de/Public BiSchwu";
          "Public Deutschkurse" = "nix-samba-fs.ad.astahhu.de/Public Deutschkurse";
          "Public Fachschaftsref" = "nix-samba-fs.ad.astahhu.de/Public Fachschaftsref";
          "Public Finanzref" = "nix-samba-fs.ad.astahhu.de/Public Finanzref";
          "Public Flüchtlingsarbeit" = "nix-samba-fs.ad.astahhu.de/Public Flüchtlingsarbeit";
          "Public Frauenref" = "nix-samba-fs.ad.astahhu.de/Public Frauenref";
          "Public HoPoref" = "nix-samba-fs.ad.astahhu.de/Public HoPoref";
          "Public Internationalesref" = "nix-samba-fs.ad.astahhu.de/Public Internationalesref";
          "Public ITref" = "nix-samba-fs.ad.astahhu.de/Public ITref";
          "Public Kommref" = "nix-samba-fs.ad.astahhu.de/Public Kommref";
          "Public Kulturref" = "nix-samba-fs.ad.astahhu.de/Public LesBiref";
          "Public Lesbiref" = "nix-samba-fs.ad.astahhu.de/Public Kulturref";
          "Public Materialbeauftragter" = "nix-samba-fs.ad.astahhu.de/Public Materialbeauftragter";
          "Public Mieterverein" = "nix-samba-fs.ad.astahhu.de/Public Mieterverein";
          "Public Oekoref" = "nix-samba-fs.ad.astahhu.de/Public Oekoref";
          "Public Praesidium" = "nix-samba-fs.ad.astahhu.de/Public Oekoref";
          "Public Presseref" = "nix-samba-fs.ad.astahhu.de/Public Praesidium";
          "Public Rechtsberatung" = "nix-samba-fs.ad.astahhu.de/Public Rechtsberatung";
          "Public Sekretariat Finanz Buchhaltung" =
            "nix-samba-fs.ad.astahhu.de/Public Sekretariat Finanz Buchhaltung";
          "Public Sozialref" = "nix-samba-fs.ad.astahhu.de/Public Sozialref";
          "Public Teamassistenz" = "nix-samba-fs.ad.astahhu.de/Public Teamassistenz";
          "Public Vorstand" = "nix-samba-fs.ad.astahhu.de/Public Vorstand";
        };
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

  sops.secrets.kea-key = {
    sopsFile = ../../secrets/nix-samba-dc/kea-key;
    owner = "named";
    format = "binary";
  };

  sops.secrets.cloudflare-dns = {
    sopsFile = ../../secrets/nix-samba-dc/cloudflare-dns;
    format = "binary";
  };

  sops.defaultSopsFile = ../../secrets/nix-samba-dc.yaml;

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
