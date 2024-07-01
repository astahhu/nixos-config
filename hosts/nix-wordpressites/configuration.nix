# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  pkgs,
  ...
}: {
  imports = [
    ../../modules/modules.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable VMWare Guest
  virtualisation.vmware.guest.enable = true;

  services.wordpress.sites."test.astahhu.de" = {
    plugins = {
      inherit (pkgs.wordpressPackages.plugins)
      static-mail-sender-configurator;
    };

    extraConfig = ''
      $_SERVER['HTTPS']='on';

      //Enable the Static Mail Sender Configuration
      if ( !defined('ABSPATH') )
        define('ABSPATH', dirname(__FILE__) . '/');
      require_once(ABSPATH . 'wp-settings.php');
      require_once ABSPATH . 'wp-admin/includes/plugin.php';
      activate_plugin( 'static-mail-sender-configurator/static-mail-sender-configurator.php' );
  '';

    languages = [ pkgs.wordpressPackages.languages.de_DE ];
    settings = {
      WPLANG = "de_DE";
      ## Mail settings
      WP_MAIL_FROM = "noreply@astahhu.de";
      FORCE_SSL_ADMIN = true;
    };
  };

  jamesofscout.impermanence = {
    enable = true; 
    persistentFullHome = false;
    defaultPath = "/persistent";
  };

  myprograms = {
    cli.better-tools.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

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

  # User Account
  users.users.florian = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.fish;
  };
  
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
