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
          "Intern Buchhaltung" = "asta-fs-v-02.asta2012.local/intern/Intern Buchhaltung";
          "Intern Deutschkurse" = "asta-fs-v-02.asta2012.local/intern/Intern Deutschkurse";
          "Intern Fachschaftsref" = "nix-samba-fs.ad.astahhu.de/Intern Fachschaftsref";
          "Intern Finanzref" = "asta-fs-v-02.asta2012.local/intern/Intern Finanzref";
          "Intern Flüchtlingsarbeit" = "asta-fs-v-02.asta2012.local/intern/Intern Flüchtlingsarbeit";
          "Intern Frauenref" = "asta-fs-v-02.asta2012.local/intern/Intern Frauenref";
          "Intern HoPoref" = "asta-fs-v-02.asta2012.local/intern/Intern HoPoref";
          "Intern Internationalesref" = "asta-fs-v-02.asta2012.local/intern/Intern Internationalesref";
          "Intern ITref" = "nix-samba-fs.ad.astahhu.de/Intern ITref";
          "Intern Kulturref" = "asta-fs-v-02.asta2012.local/intern/Intern Kulturref";
          "Intern Kommref" = "asta-fs-v-02.asta2012.local/intern/Intern Kommref";
          "Intern LesBiref" = "asta-fs-v-02.asta2012.local/intern/Intern LesBiref";
          "Intern Material" = "asta-fs-v-02.asta2012.local/intern/Intern Material";
          "Intern Materialbeauftragter" = "asta-fs-v-02.asta2012.local/intern/Intern Materialbeauftragter";
          "Intern Mieterverein" = "asta-fs-v-02.asta2012.local/intern/Intern Mieterverein";
          "Intern Oekoref" = "asta-fs-v-02.asta2012.local/intern/Intern Oekoref";
          "Intern Presseref" = "asta-fs-v-02.asta2012.local/intern/Intern Presseref";
          "Intern Rechtsberatung" = "asta-fs-v-02.asta2012.local/intern/Intern Rechtsberatung";
          "Intern Sekretariat Finanz Buchhaltung" = "asta-fs-v-02.asta2012.local/intern/Intern Sekretariat Finanz Buchhaltung";
          "Intern Sozialref" = "asta-fs-v-02.asta2012.local/intern/Intern Sozialref";
          "Intern SP" = "asta-fs-v-02.asta2012.local/intern/Intern SP";
          "Intern Steuern" = "asta-fs-v-02.asta2012.local/intern/Intern Steuern";
          "Intern Teamassistenz" = "asta-fs-v-02.asta2012.local/intern/Intern Teamassistenz";
          "Intern Vorstand" = "asta-fs-v-02.asta2012.local/intern/Intern Vorstand";
        };
        "public" = {
          "Public AntiFaRaDis" = "asta-fs-v-02.asta2012.local/public/Public AntiFaRaDis";
          "Public Autonom" = "asta-fs-v-02.asta2012.local/public/Public Autonom";
          "Public Barriereref" = "asta-fs-v-02.asta2012.local/public/Public Barriereref";
          "Public BiSchwu" = "asta-fs-v-02.asta2012.local/public/Public BiSchwu";
          "Public Deutschkurse" = "asta-fs-v-02.asta2012.local/public/Public Deutschkurse";
          "Public Fachschaftsref" = "asta-fs-v-02.asta2012.local/public/Public Fachschaftsref";
          "Public Finanzref" = "asta-fs-v-02.asta2012.local/public/Public Finanzref";
          "Public Flüchtlingsarbeit" = "asta-fs-v-02.asta2012.local/public/Public Flüchtlingsarbeit";
          "Public Frauenref" = "asta-fs-v-02.asta2012.local/public/Public Frauenref";
          "Public HoPoref" = "asta-fs-v-02.asta2012.local/public/Public HoPoref";
          "Public Internationalesref" = "asta-fs-v-02.asta2012.local/public/Public Internationalesref";
          "Public ITref" = "asta-fs-v-02.asta2012.local/public/Public ITref";
          "Public Kommref" = "asta-fs-v-02.asta2012.local/public/Public Kommref";
          "Public Kulturref" = "asta-fs-v-02.asta2012.local/public/Public LesBiref";
          "Public Lesbiref" = "asta-fs-v-02.asta2012.local/public/Public Kulturref";
          "Public Materialbeauftragter" = "asta-fs-v-02.asta2012.local/public/Public Materialbeauftragter";
          "Public Mieterverein" = "asta-fs-v-02.asta2012.local/public/Public Mieterverein";
          "Public Oekoref" = "asta-fs-v-02.asta2012.local/public/Public Oekoref";
          "Public Praesidium" = "asta-fs-v-02.asta2012.local/public/Public Oekoref";
          "Public Presseref" = "asta-fs-v-02.asta2012.local/public/Public Praesidium";
          "Public Rechtsberatung" = "asta-fs-v-02.asta2012.local/public/Public Rechtsberatung";
          "Public Sekretariat Finanz Buchhaltung" = "asta-fs-v-02.asta2012.local/public/Public Sekretariat Finanz Buchhaltung";
          "Public Sozialref" = "asta-fs-v-02.asta2012.local/public/Public Sozialref";
          "Public Teamassistenz" = "asta-fs-v-02.asta2012.local/public/Public Teamassistenz";
          "Public Vorstand" = "asta-fs-v-02.asta2012.local/public/Public Vorstand";
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
