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
    services.xserver.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    hardware.pulseaudio.enable = false;


    environment.gnome.excludePackages = with pkgs; [
      epiphany
    ];

    environment.systemPackages = with pkgs; [
      gnome.gnome-boxes
      gnomeExtensions.gsconnect
    ];

  };
}
