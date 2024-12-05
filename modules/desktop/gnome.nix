{ config
, pkgs
, lib
, ...
}: {
  options = {
    astahhu.desktop.gnome.enable = lib.mkEnableOption "Enable Gnome";
  };

  config = lib.mkIf config.astahhu.desktop.gnome.enable {
    services = {
      xserver = {
        enable = true;
        desktopManager.gnome.enable = true;
        displayManager.gdm.enable = true;
      };
    };
    hardware.pulseaudio.enable = false;

    environment.gnome.excludePackages = lib.mkIf (!config.astahhu.desktop.firefox.enable) (with pkgs; [
      epiphany
    ]);

    environment.systemPackages = with pkgs; [
      gnomeExtensions.gsconnect
    ];

    home-manager.sharedModules = [
      {
        dconf.settings = {
          # ...
          "org/gnome/shell" = lib.mkDefault {
            favorite-apps = [
              #(lib.mkIf config.astahhu.desktop.firefox.enable "firefox-esr.desktop")
              "org.gnome.Nautilus.desktop"
            ];
          };
        };
      }
    ];
  };
}
