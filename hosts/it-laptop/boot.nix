{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.kernelParams = [ "quiet" ];

  # luks
  #boot.initrd.systemd.enable = true;
  #boot.plymouth.enable = true;
}
