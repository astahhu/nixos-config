{
  config,
  lib,
  pkgs,
  ...
}: {
  # Boot
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = ["quiet"];

  # luks
  boot.initrd.systemd.enable = true;
  boot.plymouth.enable = true;
}
