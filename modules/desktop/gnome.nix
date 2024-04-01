{
  config,
  pkgs,
  stylix,
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
    stylix.targets.gnome.enable = true;
    stylix.image = pkgs.fetchurl {
      url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
      sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
    };

    environment.gnome.excludePackages = with pkgs; [
      epiphany
    ];

    environment.systemPackages = with pkgs; [
       gnome.gnome-boxes
       gnomeExtensions.gsconnect
    ];

    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/monokai.yaml";
    stylix.fonts.monospace = {
      package = pkgs.nerdfonts.override {
        fonts = [
          "FiraCode"
        ];
      };
      name = "FiraCode Nerd Font Mono";
    };
  };
}
