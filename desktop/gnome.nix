{ config, pkgs, stylix, ... }: {
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  hardware.pulseaudio.enable = false;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/monokai.yaml";
  stylix.fonts.monospace = {
      package = (pkgs.nerdfonts.override { fonts = [
      "FiraCode"
    ];});
      name = "FiraCode Nerd Font Mono";
    };
}
