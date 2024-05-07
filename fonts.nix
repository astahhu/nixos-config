{pkgs, ...}: {
  fonts.packages = with pkgs; [
    open-dyslexic
    (nerdfonts.override {
      fonts = [
        "FiraCode"
      ];
    })
  ];
}
