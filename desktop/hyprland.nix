{config, pkgs, ...} : {

  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
   };
   
  };

  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtwayland
    qt6.qtwayland
    kitty
    firefox
  ];
}
