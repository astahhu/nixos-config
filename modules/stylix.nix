{ config
, pkgs
, lib
, inputs
, ...
}: {
  options = {
    myprograms.stylix.enable = lib.mkEnableOption "Enable Stylix";
  };

  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  config = lib.mkIf config.myprograms.stylix.enable {
    stylix = {
      enable = true;
      targets.gnome.enable = true;

      image = lib.mkDefault (pkgs.fetchurl {
        url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
        sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
      });

      base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/monokai.yaml";
      fonts.monospace = lib.mkDefault {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font Mono";
      };
    };
  };
}
