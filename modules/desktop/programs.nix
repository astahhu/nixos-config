{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    astahhu.desktop.programs.enable = lib.mkEnableOption "Enable Standard Desktop Programs";
  };

  imports = [
    ./firefox.nix
  ];

  config = lib.mkIf config.astahhu.desktop.programs.enable {
    astahhu.desktop.firefox.enable = true;
    environment.systemPackages = with pkgs; [
      onlyoffice-bin_latest
      nextcloud-client
      thunderbird
    ];

    nixpkgs.config.permittedInsecurePackages = [
      "electron-25.9.0"
    ];
  };
}
