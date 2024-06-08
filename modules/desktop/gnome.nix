{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    myprograms.desktop.gnome.enable = lib.mkEnableOption "Enable Gnome";
  };

  config = lib.mkIf config.myprograms.desktop.gnome.enable {
    services = {
      xserver = {
        enable = true;
        desktopManager.gnome.enable = true;
        displayManager.gdm.enable = true;
      };
    };
    hardware.pulseaudio.enable = false;


    environment.gnome.excludePackages = lib.mkIf  (!config.myprograms.desktop.firefox.enable) (with pkgs; [
      epiphany
    ]);

    environment.systemPackages = with pkgs; [
      gnome.gnome-boxes
      gnomeExtensions.gsconnect
    ];

    home-manager.sharedModules = [
      {
	dconf.settings = {
	  # ...
	  "org/gnome/shell" = lib.mkDefault {
	    favorite-apps = [
	      (lib.mkIf config.myprograms.desktop.firefox.enable "firefox-esr.desktop")
	      "org.gnome.Nautilus.desktop"
	    ];
	  };
	};
      }

    ];


  };
}
