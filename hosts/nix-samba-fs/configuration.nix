# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{ pkgs
, config
, lib
, ...
}: {

  astahhu.common = {
    is_server = true;
    is_qemuvm = true;
    disko = {
      enable = true;
      device = "/dev/sda";
    };
  };

  sops.secrets.cloudflare-dns = {
    sopsFile = ../../secrets/nix-samba-fs/cloudflare-dns;
    format = "binary";
  };

  #sops.defaultSopsFile = ../../secrets/nix-samba-fs.yaml;

  astahhu.services.samba = {
    workgroup = "AD.ASTAHHU";
    domain = "ad.astahhu.de";
    acme = {
      enable = true;
      email = "it@asta.hhu.de";
    };
    fs = {
      enable = true;
      shares = {
        scans.browseable = "yes";
        home.browseable = "yes";
        profile = {
          comment = "Users profiles";
          "read only" = "no";
          browseable = "no";
          "csc policy" = "disable";
          "inherit owner" = "no";
          "inherit permissions" = "no";
        };
        software.browseable = "yes";
        # Intern (Nur die jeweiligen Personen können schreiben)
        "Intern AntiFaRaDis".browseable = "no";
        "Intern Autonom".browseable = "no";
        "Intern AWO".browseable = "no";
        "Intern Barriereref".browseable = "no";
        "Intern BiSchwu".browseable = "no";
        "Intern Buchhaltung".browseable = "no";
        "Intern Deutschkurse".browseable = "no";
        "Intern Fachschaftsref".browseable = "no";
        "Intern Finanzref".browseable = "no";
        "Intern Flüchtlingsarbeit".browseable = "no";
        "Intern Frauenref".browseable = "no";
        "Intern HoPoref".browseable = "no";
        "Intern Internationalesref".browseable = "no";
        "Intern IT Ref".browseable = "no";
        "Intern Kommref".browseable = "no";
        "Intern Kulturref".browseable = "no";
        "Intern LesBiref".browseable = "no";
        "Intern Material".browseable = "no";
        "Intern Materialbeauftragter".browseable = "no";
        "Intern Mieterverein".browseable = "no";
        "Intern Oekoref".browseable = "no";
        "Intern Presseref".browseable = "no";
        "Intern Rechtsberatung".browseable = "no";
        "Intern Sekreteriat Finanz Buchhaltung".browseable = "no";
        "Intern Sozialref".browseable = "no";
        "Intern SP".browseable = "no";
        "Intern Steuern".browseable = "no";
        "Intern Teamassistenz".browseable = "no";
        "Intern Vorstand".browseable = "no";
        # Public (Nur die jeweiligen Personen können schreiben, alle können lesen.)
        "Public AntiFaRaDis".browseable = "yes";
        "Public Autonom".browseable = "yes";
        "Public Barriereref".browseable = "yes";
        "Public BiSchwu".browseable = "yes";
        "Public Buchhaltung".browseable = "yes";
        "Public Deutscchkurse".browseable = "yes";
        "Public Fachschaftsref".browseable = "yes";
        "Public Finanzref".browseable = "yes";
        "Public Flüchtlingsarbeit".browseable = "yes";
        "Public Frauenref".browseable = "yes";
        "Public HoPoref".browseable = "yes";
        "Public Internationalesref".browseable = "yes";
        "Public ITref".browseable = "yes";
        "Public Kommref".browseable = "yes";
        "Public Kulturref".browseable = "yes";
        "Public LesBiref".browseable = "yes";
        "Public Materialbeauftragter".browseable = "yes";
        "Public Mieterverein".browseable = "yes";
        "Public Oekoref".browseable = "yes";
        "Public Praesidium".browseable = "yes";
        "Public Presseref".browseable = "yes";
        "Public Rechtsberatung".browseable = "yes";
        "Public Sekreteriat Finanz Buchhaltung".browseable = "yes";
        "Public Sozialref".browseable = "yes";
        "Public Teamassistenz".browseable = "yes";
        "Public Vorstand".browseable = "yes";
      };
    };
  };


  # Networking
  networking.firewall.enable = true;

  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.hostName = "nix-samba-fs";
  networking.domain = "ad.astahhu.de";

  environment.etc = {
    "resolv.conf".text = lib.mkForce ''
      nameserver 134.99.154.200
      nameserver 134.99.154.201
      search ad.astahhu.de
    '';
    hosts.text = lib.mkForce ''
      127.0.0.1 localhost
      134.99.154.205 nix-samba-fs.ad.astahhu.de nix-samba-fs
    '';
  };

  time.timeZone = "Europe/Berlin";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  security.pam.sshAgentAuth.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.10"; # Did you read the comment?

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;
}
