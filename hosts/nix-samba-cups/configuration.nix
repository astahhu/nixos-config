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
    is_qemuvm = true;
    disko = {
      enable = true;
      device = "/dev/sda";
    };
  };

  #sops.defaultSopsFile = ../../secrets/nix-samba-fs.yaml;

  astahhu.services.samba-fs = {
    enable = true;
    shares.scans.browseable = "yes";
  };

  # Networking
  networking.firewall.enable = true;

  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.hostName = "nix-samba-fs";
  environment.etc = {
    "resolv.conf".text = ''
      nameserver 134.99.154.200
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
