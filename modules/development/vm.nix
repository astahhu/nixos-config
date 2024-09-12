{
  config,
  pkgs,
  lib,
  ...
}: {
  options.astahhu.development.vm.enable = lib.mkEnableOption "Enable Virt Manager";

  config = lib.mkIf config.astahhu.development.vm.enable {
    # Enable dconf (System Management Tool)
    programs.dconf.enable = true;

    # Install necessary packages
    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      spice
      nmap
      spice-gtk
      spice-protocol
      win-virtio
      win-spice
    ];

    # Manage the virtualisation services
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
          ovmf.enable = true;
          ovmf.packages = [pkgs.OVMFFull.fd];
        };
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;
  };
}
