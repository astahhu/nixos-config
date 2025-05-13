{ pkgs, lib, config, modulesPath, ... }: {

  imports = [
    ./qemu-hardwareconfig.nix
    ./users.nix
    ./server.nix
    ./proxmox-lxc.nix
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];


  options.astahhu.common = {
    is_server = lib.mkEnableOption "Enables default server settings";
    is_qemuvm = lib.mkEnableOption "Set if this server is a qemuvm, this will setup the default hardware config";
    uses_btrfs = lib.mkEnableOption "Does this Server use a btrfs Filesystem (Snapshots and Backups)";
    disko.enable = lib.mkEnableOption "Use disko for disk management";
    disko.device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/sda";
    };
    disko.swap = lib.mkOption {
      type = lib.types.str;
      default = "8G";
    };
  };

  config = lib.mkMerge [
    {

      proxmoxLXC.enable = lib.mkDefault false;
      astahhu = {
        cli.better-tools.enable = true;
        common.uses_btrfs = lib.mkDefault config.astahhu.common.disko.enable;
      };
      time.timeZone = "Europe/Berlin";
      i18n.defaultLocale = "en_US.UTF-8";
      console = {
        keyMap = "us";
      };


      networking.firewall = {
        enable = true;
      };

      nix.settings.trusted-users = [ "root" "@wheel" ];


    }
    (lib.mkIf config.astahhu.common.disko.enable (import ./disko.nix {
      device = config.astahhu.common.disko.device;
      swap = config.astahhu.common.disko.swap;
    }))
  ];

}
