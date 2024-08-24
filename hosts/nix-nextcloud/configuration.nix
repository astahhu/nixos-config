# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../users/admin-users.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable VMWare Guest
  virtualisation.vmware.guest.enable = true;

  networking.hostName = "nix-nextcloud"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  sops.defaultSopsFile = ../../secrets/nix-nextcloud.yaml;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List services that you want to enable:
  nix-tun = {
    storage.persist.enable = true;
    services.traefik = {
      enable = true;
      letsencryptMail = "it@asta.hhu.de";
    };
    services.containers.nextcloud = {
      enable = true;
      hostname = "nextcloud.astahhu.de";
      package = pkgs.nextcloud27;
    };
  };
  containers.nextcloud.config = {
    imports = [ inputs.nix-topology.nixosModules.default];
    services.nextcloud.database.createLocally = lib.mkForce false;
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
    };

  };
  
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  security.pam.sshAgentAuth.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

  security.pki.certificates = [
    ''
            -----BEGIN CERTIFICATE-----
      MIIEOTCCAyGgAwIBAgIUOHFmcxpzp3l8pf+DtUFNALkgzEcwDQYJKoZIhvcNAQEL
      BQAwgaoxCzAJBgNVBAYTAkRFMRwwGgYDVQQIDBNOb3JkcmhlaW4tV2VzdGZhbGVu
      MRYwFAYDVQQHDA1Ew4PCvHNzZWxkb3JmMRUwEwYDVQQKDAxBU3RBIGRlciBISFUx
      DzANBgNVBAsMBklULVJlZjEfMB0GA1UEAwwWc2FtYmEtZGMuYWQuYXN0YWhodS5k
      ZTEcMBoGCSqGSIb3DQEJARYNYXN0YWl0QGhodS5kZTAgFw0yMzEyMzAwMzQzMTJa
      GA8zMDA0MDMwMjAzNDMxMlowgaoxCzAJBgNVBAYTAkRFMRwwGgYDVQQIDBNOb3Jk
      cmhlaW4tV2VzdGZhbGVuMRYwFAYDVQQHDA1Ew4PCvHNzZWxkb3JmMRUwEwYDVQQK
      DAxBU3RBIGRlciBISFUxDzANBgNVBAsMBklULVJlZjEfMB0GA1UEAwwWc2FtYmEt
      ZGMuYWQuYXN0YWhodS5kZTEcMBoGCSqGSIb3DQEJARYNYXN0YWl0QGhodS5kZTCC
      ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPNLvpIkY1VkgjxubzSy8f75
      SqG/Ei58X77zhdaONxv2H2OudINXUMIqFGGNcKfkPo+cFZZJZY7Yog4JFaayCNdf
      4QZbPFV8X7af+e651Biuofsc95rR84UwROoJAXjpR0a+F57l+3JytF3mEDFSFmMy
      f+A5Mj2F4hCkXt3pGBsjY6SszYhQYkQTxa7oGobXTPDQcNm2QUHkkTHTj9jOKyAT
      k68sP+gY7fhA0TdTEQl2i3GkXQaNeoDRXOqY1boPUD/aS5Iq1kaCrXM3/pBOyLGh
      jgMS5lu9FvB7VehQ+a2CTT2lsH+tLQ7Tee9xRZKAzRw4jEQKEMQ52HYNyJpXbLkC
      AwEAAaNTMFEwHQYDVR0OBBYEFG6lrXrIeQDLpNtAbaTtQq38lerFMB8GA1UdIwQY
      MBaAFG6lrXrIeQDLpNtAbaTtQq38lerFMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZI
      hvcNAQELBQADggEBAL/IO+ME0v49YWOgbhE4XxmJk8l1kFI9yi7cjChLdAkU9Koa
      AWuBbwMtS1wHq9jIzr5Hbon13AOOglf5TV8wo06kmN2qorkuerGuh5m5sZoP1mWv
      cng/Kl0bRKL/RFZRhqqF3CwXm2k6+zbkeUTUbTHuqkKLgyDesVjaJC0XxyMlxR0N
      25U3rgEKFb2Rc4vYE3Emd6nSsrcCubUoDI/iyYsbTClct0kqsnsNeV3hOlXqCQ6f
      vlfyEtlpOpUU60aOnxUwT4yqchhe6cg53JFPLRAxjDUW7yYJR1WXP+SPB1+wnFg2
      LiJjkm+8DliLET2JyhFqWV0n4ljhkwUNBeCvTGA=
      -----END CERTIFICATE-----
    ''
  ];
}
