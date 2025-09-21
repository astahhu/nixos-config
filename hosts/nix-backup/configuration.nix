# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ config
, lib
, pkgs
, inputs
, ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.swraid.mdadmConf = ''
    MAILADDR = it@asta.hhu.de
    MAILFROM = backupserver
  '';

  networking.hostName = "nix-backup"; # Define your hostname.
  # Pick only one of the below networking options.
  sops.defaultSopsFile = ../../secrets/nix-backup.yaml;
  sops.gnupg.sshKeyPaths = [
    "/sops-ssh/host_rsa"
  ];

  nix-tun.alloy = {
    enable = true;
    loki-host = "loki.astahhu.de";
    prometheus-host = "prometheus.astahhu.de";
  };

  nix-tun.storage.backup = {
    enable = true;
    nixosConfigs = inputs.self.nixosConfigurations;

    server = {
      # This would backup the subvolume /a/d on the host example.de.
      # On which btrfs is mounted as the rootfs
      # example.de = {
      #   btrfs_base = "/";
      #   subvolumes = [
      #     "/a/d"
      #   ];
      # };
    };
  };

  environment.systemPackages = with pkgs; [
    git
  ];

  programs.gnupg.agent.enable = true;

  astahhu.common.disko.enable = lib.mkForce false;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

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
}
