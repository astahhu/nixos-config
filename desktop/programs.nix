{ pkgs, ...} : {
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    onlyoffice-bin_7_5
  ];
}
