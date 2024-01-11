{ pkgs, ...} : {
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    onlyoffice-bin_7_5
    bootstrap-studio
    thunderbird
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
}
