{
  config,
  pkgs,
  hyprland-contrib,
  lib,
  ...
}: let
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };
in {
  options = {
    myprograms.desktop.hyprland.enable = lib.mkEnableOption "Enable Hyprland";
  };

  config = lib.mkIf config.myprograms.desktop.hyprland.enable {
    services.udisks2.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.enable = true;
    programs.hyprland = {
      enable = true;
      xwayland = {
        enable = true;
      };
    };

    services.logind.extraConfig = ''
      HandleLidSwitch=lock
    '';

    security.pam.services.swaylock = {};

    environment.systemPackages = with pkgs; [
      udiskie
      configure-gtk
      swaylock
      libsForQt5.qt5.qtwayland
      hyprpicker
      hyprland-contrib.packages.${system}.grimblast
      qt6.qtwayland
      glib
      kitty # Terminal Emulator
      grim # Screenshots
      slurp # Select Screen Area for Screenschots etc.
      dracula-theme # gtk theme
      gnome3.adwaita-icon-theme
    ];
  };
}
