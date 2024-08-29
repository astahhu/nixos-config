# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{pkgs, ...}: {
  imports = [
    ../../modules/modules.nix
    ./hardware-configuration.nix
  ];



  # Change for each System
  networking.hostName = "nix-authentik";

  # Uncomment if you need Secrets for this Hosts, AFTER the first install  
  # sops.defaultSopsFile = ../../secrets/nix-sample-server.yaml;

  # Networking
  networking.firewall.enable = true;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  nix-tun.services.containers.authentik = {
    enable = true;
    hostname = "authentik.astahhu.de";
    envFile = ../../secrets/nix-authentik/authentik.yaml;
    mail = {
      host = "mail.hhu.de";
      port = 465;
      username = "astait";
      from = "it@asta.hhu.de";
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

  # Enable VMWare Guest
  virtualisation.vmware.guest.enable = true;
  # Enable the Persist Storage Module
  nix-tun.storage.persist.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  security.pam.sshAgentAuth.enable = true;

  myprograms.cli.better-tools.enable = true;

  nixpkgs.config.allowUnfree = true;
}
