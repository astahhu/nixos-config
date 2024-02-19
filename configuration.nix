# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, hyprland-contrib, lib, ... }:

{
  imports =
    [
      ./fonts.nix
      ./desktop/gnome.nix
      ./desktop/programs.nix
      ./services/tailscale.nix
      ./cli/better-tools.nix
    ];

  services = {
    fprintd.enable = true;
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

  nix.registry = {
    nixpkgs.to = {
      type = "path";
      path = pkgs.path;
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  hardware.bluetooth.enable = true;
  
  # Yubikey
  services.pcscd.enable = true;
  services.blueman.enable = true;
  
  # Networking
  networking.firewall.enable = false;
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  services.tailscale.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
  #  font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ 
    pkgs.epson-escpr
    pkgs.epson-escpr2
  ];
  virtualisation.docker.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  # for a WiFi printer
  virtualisation.libvirtd.enable = true;
  services.avahi.openFirewall = true;

  # User Account
  users.users.florian = {
    isNormalUser = true;
    initialPassword = "";
    extraGroups = [ "wheel" "networkmanager" "uinput" "input"];
    shell = pkgs.fish;
  };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.florian = import ./home/florian.nix;
  

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    sox
    git
    lsd
    home-manager
    davinci-resolve
    docker-compose
    gnomeExtensions.gsconnect
    gnupg
    opensc
    gnupg-pkcs11-scd
    pinentry-curses
    gnome.gnome-boxes
    streamdeck-ui
  ];

  programs.java.enable = true;
  programs.java.package = pkgs.jdk21;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
    enableSSHSupport = true;
  };
  ## Fix for GnuPG and PCSC colnflict
  home-manager.sharedModules = [
    { 
      home.file.".gnupg/scdaemon.conf".text = ''
        disable-ccid
      '';
    }
  ];

  # List services that you want to enable:
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.udev.extraRules = ''
     KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = true;

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
