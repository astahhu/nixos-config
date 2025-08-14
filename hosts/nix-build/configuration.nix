# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{ pkgs, config, modulesPath, lib, ... }: {

  astahhu.common.is_server = true;
  astahhu.common.is_lxc = true;

  # Change for each System
  networking = {
    hostName = lib.mkForce "nix-build";
    domain = "ad.astahhu.de";
    useDHCP = false;
  };

  systemd.network = {
    enable = true;
    networks."astahhu" = {
      name = "eth0";
      gateway = [
        "134.99.154.1"
      ];
      dns = [
        "134.99.154.200"
        "134.99.154.201"
      ];
      address = [
        "134.99.154.210/24"
      ];
      ntp = [
        "134.99.154.200"
        "134.99.154.201"
      ];
      domains = [
        "ad.astahhu.de"
        "asta2012.local"
      ];
    };
  };

  services.resolved.fallbackDns = [ "134.99.154.200" "134.99.154.201" ];

  sops.defaultSopsFile = ../../secrets/nix-build.yaml;
  sops.secrets.github-token = { };

  users.groups.github-runner = { };
  services.github-runners = {
    nix-deploy = {
      enable = true;
      name = "nix-deploy";
      tokenFile = config.sops.secrets.github-token.path;
      url = "https://github.com/astahhu/nixos-config";
      extraLabels = [ "deploy" ];
      noDefaultLabels = true;
      extraPackages = [
        pkgs.nix
        pkgs.deploy-rs
        pkgs.openssh
      ];
      replace = true;
      serviceOverrides = {
        BindPaths = "/nix/store /nix/var/nix/db /nix/var/nix/daemon-socket";
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.10"; # Did you read the comment?
}
