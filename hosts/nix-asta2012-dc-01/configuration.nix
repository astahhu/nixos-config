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
  services.samba.settings.global = {
    "additional dns hostnames" = "asta2012";
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
          "Intern Sekretariat Finanz Buchhaltung" = "nix-samba-fs.ad.astahhu.de/Intern Sekretariat Finanz Buchhaltung";
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
          "Public Sekretariat Finanz Buchhaltung" = "nix-samba-fs.ad.astahhu.de/Public Sekretariat Finanz Buchhaltung";
          "Public Sozialref" = "nix-samba-fs.ad.astahhu.de/Public Sozialref";
          "Public Teamassistenz" = "nix-samba-fs.ad.astahhu.de/Public Teamassistenz";
          "Public Vorstand" = "nix-samba-fs.ad.astahhu.de/Public Vorstand";
        };
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
