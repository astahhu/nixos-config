# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  pkgs,
  config,
  ...
}: {
  imports = [
    ../../fonts.nix
    ../../modules/modules.nix
  ];

  #jamesofscout.impermanence = {
  #  enable = true; 
  #  persistentFullHome = true;
  #  defaultPath = "/persistent";
  #};

  jamesofscout.yubikey-gpg.enable = true;
  myprograms = {
    desktop.gnome.enable = true;
    desktop.programs.enable = true;
    cli.better-tools.enable = true;
    cli.nixvim.enable = true;
  };

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

  # User Account
  users.users.florian = {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = ["wheel" "networkmanager" "uinput" "input" "docker"];
    shell = pkgs.fish;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.florian = import ../../home/florian.nix;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    sox
    solaar
    wireguard-tools
  ];

  programs.java.enable = true;
  programs.java.package = pkgs.jdk21;
  
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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
