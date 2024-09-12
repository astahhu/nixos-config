# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{pkgs, config, lib, ...}: {
  imports = [
    ../../modules/modules.nix
    ./hardware-configuration.nix
  ];
  
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #sops.defaultSopsFile = ../../secrets/nix-samba-fs.yaml;


  nix-tun.storage.persist = {
    enable = true;
    is_server = true;
  };

  myprograms = {
    cli.better-tools.enable = true;
  };

  systemd.timers = lib.attrsets.mapAttrs' (name: value: {
    name = "rclone-${name}";
    value = {
      wantedBy = [ "timers.target" ];
	timerConfig = {
	  OnBootSec = "5m";
	  OnUnitActiveSec = "1m";
	  Unit = "rclone-${name}.service";
      };
    };
  })(lib.attrsets.filterAttrs (name: value: lib.strings.hasPrefix "Intern" name) config.astahhu.services.samba-fs.shares);

  systemd.services = lib.attrsets.mapAttrs' (name: value: {
    name = "rclone-${name}";
    value = {
      script = ''
	${pkgs.rclone} sync -M 'asta2012:Intern/${name}' '/persist/samba-shares/${name}
      '';
      serviceConfig = {
	Type = "oneshot";
	User = "root";
      };
    };
  })(lib.attrsets.filterAttrs (name: value: lib.strings.hasPrefix "Intern" name) config.astahhu.services.samba-fs.shares);

  astahhu.services.samba-fs = {
    enable = true;
    shares = { 
      scans.browseable = "yes";
      home.browseable = "yes";
      profile.browseable = "yes";
      # Intern (Nur die jeweiligen Personen können schreiben)
      "Intern AntiFaRaDis".browseable = "yes";
      "Intern Autonom".browseable = "yes";
      "Intern AWO".browseable = "yes";
      "Intern Barriereref".browseable = "yes";
      "Intern BiSchwu".browseable = "yes";
      "Intern Buchhaltung".browseable = "yes";
      "Intern Deutschkurse".browseable = "yes";
      "Intern Fachschaftsref".browseable = "yes";
      "Intern Finanzref".browseable = "yes";
      "Intern Flüchtlingsarbeit".browseable = "yes";
      "Intern Frauenref".browseable = "yes";
      "Intern HoPoref".browseable = "yes";
      "Intern Internationalesref".browseable = "yes";
      "Intern IT Ref".browseable = "yes";
      "Intern Kommref".browseable = "yes";
      "Intern Kulturref".browseable = "yes";
      "Intern LesBiref".browseable = "yes";
      "Intern Material".browseable = "yes";
      "Intern Materialbeauftragter".browseable = "yes";
      "Intern Mieterverein".browseable = "yes";
      "Intern Oekoref".browseable = "yes";
      "Intern Presseref".browseable = "yes";
      "Intern Rechtsberatung".browseable = "yes";
      "Intern Sekreteriat Finanz Buchhaltung".browseable = "yes";
      "Intern Sozialref".browseable = "yes";
      "Intern SP".browseable = "yes";
      "Intern Steuern".browseable = "yes";
      "Intern Teamassistenz".browseable = "yes";
      "Intern Vorstand".browseable = "yes";
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

  nixpkgs.config.allowUnfree = true;

  # Networking
  networking.firewall.enable = true;
  
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.hostName = "nix-samba-fs";
  environment.etc = {
    "resolv.conf".text = lib.mkForce ''
    nameserver 134.99.154.228
    nameserver 134.99.154.201
    search ad.astahhu.de
    '';
    hosts.text = lib.mkForce ''
    127.0.0.1 localhost
    134.99.154.59 nix-samba-fs.ad.astahhu.de nix-samba-fs
    '';
    "nsswitch.conf".text = lib.mkForce ''
    passwd: files winbind
    group: files winbind
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
