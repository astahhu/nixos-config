{pkgs, ...}: {
  home.packages = with pkgs; [
    gcc
    rustup
    pkg-config
    openssl
  ];
  home.sessionVariables = rec {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
}
