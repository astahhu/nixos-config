{
  config,
  pkgs,
  services,
  stylix,
  ...
}: {
  imports = [
    ./editor/codium.nix
    ./theme.nix
    ./languages/rust.nix
  ];

  home.stateVersion = "23.11";
  home.username = "florian";
  home.homeDirectory = "/home/florian";
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  home.packages = with pkgs; [
    texlive.combined.scheme-full
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
        "firefox-esr.desktop"
        "code.desktop"
        "org.gnome.Terminal.desktop"
        "dev.alextren.Spot.desktop"
        "org.gnome.Console.desktop"
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
    shellInit = "
      set -p fish_function_path ${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d\n
      fenv source ${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh > /dev/null
      ";
  };

  programs.git = {
    enable = true;
    diff-so-fancy.enable = true;
    aliases = {
      lg = "log --color --graph --date=format:'%Y-%m-%d %H:%M:%S' --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'";
    };
    userName = "florian";
    userEmail = "florian.schubert.sg@gmail.com";
    extraConfig = {
      pull.rebase = true;
    };
  };
}
