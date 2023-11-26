{ stylix, pkgs, ... } : {
  stylix.image = pkgs.fetchurl {
    url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
    sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
  };
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/monokai.yaml";
  stylix.polarity = "dark";
  stylix.fonts.monospace = {
      package = (pkgs.nerdfonts.override { fonts = [
      "FiraCode"
    ];});
      name = "FiraCode Nerd Font Mono";
    };
  stylix.targets.kitty.enable = true;
}