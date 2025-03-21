# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{ pkgs
, inputs
, config
, ...
}: {
  imports = [
    ../../fonts.nix
    ../../modules
    ../../users/admin-users.nix
  ];

  astahhu.development.vm.enable = true;
  astahhu.desktop = {
    gnome.enable = true;
    programs.enable = true;
  };
  nix-tun.yubikey-gpg.enable = true;
  nix-tun.storage.persist = {
    enable = true;
    subvolumes = {
      "home" = {
        bindMountDirectories = true;
        directories = {
          "/home/florian" = {
            owner = "florian";
            group = "florian";
            mode = "0700";
          };
        };
      };
    };
  };

  networking.hostName = "it-laptop";

  sops.defaultSopsFile = ../../secrets/it-laptop.yaml;

  services = {
    fprintd.enable = false;
    pipewire.enable = true;
    pipewire.audio.enable = true;
    pipewire.alsa.enable = true;
    pipewire.pulse.enable = true;
  };

  services.mpd = {
    enable = true;
    startWhenNeeded = true;
  };

  nixpkgs.config.allowUnfree = true;

  hardware.bluetooth.enable = true;
  programs.nano.enable = true;
  # Networking

  networking.firewall.enable = true;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.epson-escpr
    pkgs.epson-escpr2
  ];

  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  # for a WiFi printer
  virtualisation.libvirtd.enable = true;
  services.avahi.openFirewall = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.florian = import ../../home/florian.nix;
  astahhu.common.admin-users.florian.setPassword = false;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    rustc
    cargo
    deploy-rs
    samba
    pinta
    apache-directory-studio
    sox
    solaar
    wireguard-tools
  ];

  programs.java.enable = true;
  programs.java.package = pkgs.jdk21;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  security.pam.sshAgentAuth.enable = true;
  programs.ssh.extraConfig = ''
    Host *
      ForwardAgent = yes
  '';

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
