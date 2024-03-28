{pkgs, ...}: {
  home.packages = with pkgs; [
    jdk
  ];
  home.sessionVariables = rec {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
}
