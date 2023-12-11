{ config, pkgs, services, stylix, ...} : {

  imports = [
    ./editor/intelij.nix
    ./editor/codium.nix
    ./editor/nvim.nix
    ./theme.nix
    ./languages/rust.nix
  ];

  home.stateVersion = "23.11";
  home.username = "florian";
  home.homeDirectory = "/home/florian";
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };
  
  home.packages = with pkgs; [
    texlive.combined.scheme-full
    obsidian
    python3
    spot  
    dunst
    gnomeExtensions.gsconnect
    yubioath-flutter
    kitty
  ];

  dconf.settings = {
    # ...
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "code.desktop"
        "org.gnome.Terminal.desktop"
        "spot.desktop"
        "org.gnome.Nautilus.desktop"
      ];
       enabled-extensions = [
        "gsconnect@andyholmes.github.io"
      ];
    };
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "fenv";
        src = pkgs.fishPlugins.foreign-env;
      }
    ];
    shellInit =  "
      set -p fish_function_path ${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d\n
      fenv source ${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh > /dev/null
      ";
  };
}