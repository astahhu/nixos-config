# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Desktop
  programs.sway.enable = true;
  xdg.portal.wlr.enable = true;
  services.pipewire.enable = true;
  services.pipewire.audio.enable = true;
  services.pipewire.pulse.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.efi.canTouchEfiVariables = true;

  # grub
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    enableCryptodisk = true;
    device = "nodev";
  };

  # luks
  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-uuid/639bca5e-580f-4bbd-9b12-1db78906d356";
      preLVM = true;
    };
  };
  
  # Networking
  networking.hostName = "Kakariko"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # User Account
  users.users.florian = {
    isNormalUser = true;
    initialPassword = "";
    extraGroups = [ "wheel" "networkmanager"];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    starship
    wayfire
    firefox
    lsd
    tree
    home-manager
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # 

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;

}
