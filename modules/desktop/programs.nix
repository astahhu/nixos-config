{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    myprograms.desktop.programs.enable = lib.mkEnableOption "Enable Standard Desktop Programs";
  };

  config = lib.mkIf config.myprograms.desktop.programs.enable {
    programs.firefox.enable = true;
    environment.systemPackages = with pkgs; [
      onlyoffice-bin_latest
      bootstrap-studio
      thunderbird
    ];

    nixpkgs.config.permittedInsecurePackages = [
      "electron-25.9.0"
    ];
  };
}
