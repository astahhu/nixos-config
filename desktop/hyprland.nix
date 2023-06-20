{config, pkgs, ...} : {

  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
   };
   
  };

  environment.systemPackages = with pkgs; [
    swaylock
    libsForQt5.qt5.qtwayland
    qt6.qtwayland
    kitty # Terminal Emulator
    firefox
    grim # Screenshots
    slurp # Select Screen Area for Screenschots etc.
  ];
}
