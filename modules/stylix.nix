{ config,
  pkgs,
  lib,
  stylix,
  ... } : {
  options = {
    myprograms.stylix.enable = lib.mkEnableOption "Enable Stylix";
  };

  config = lib.mkIf config.myprograms.stylix.enable {
    stylix = { 
      targets.gnome.enable = true;
	image = pkgs.fetchurl {
	url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
	sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
      };

      base16Scheme = "${pkgs.base16-schemes}/share/themes/monokai.yaml";
      fonts.monospace = {
	package = pkgs.nerdfonts.override {
	  fonts = [
	    "FiraCode"
	  ];
	};
	name = "FiraCode Nerd Font Mono";
      };
    };
  };
}
