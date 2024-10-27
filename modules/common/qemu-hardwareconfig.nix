    { modulesPath, lib, config, ...}: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

    config = lib.mkIf config.astahhu.common.is_qemuvm {
    services.qemuGuest.enable = true;

    nixpkgs.config.allowUnfree = true;
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
    boot.initrd.kernelModules = ["dm-snapshot"];
    boot.kernelModules = [];
    boot.extraModulePackages = [];

    fileSystems."/persist".neededForBoot = true;

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.ens33.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
  }
