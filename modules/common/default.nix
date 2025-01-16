{ pkgs, lib, config, modulesPath, ... }: {

  imports = [
    ./qemu-hardwareconfig.nix
    ./users.nix
  ];

  options.astahhu.common = {
    is_server = lib.mkEnableOption "Enables default server settings";
    is_qemuvm = lib.mkEnableOption "Set if this server is a qemuvm, this will setup the default hardware config";
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
      astahhu = {
        cli.better-tools.enable = true;
      };

      nix-tun.storage.persist = lib.mkIf config.astahhu.common.is_server {
        enable = true;
        is_server = true;
      };

      nix.settings.trusted-users = [ "root" "@wheel" ];

      services.openssh.enable = lib.mkIf config.astahhu.common.is_server true;
      security.pam.sshAgentAuth.enable = lib.mkIf config.astahhu.common.is_server true;

      services.btrbk.sshAccess = lib.mkIf config.astahhu.common.is_server [
        {
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPGx5yVTgRy/oXLuGvsK9PTr0hHbUCLz/+cKukb+L5K btrbk@asta-backup";
          roles = [
            "info"
            "source"
            "target"
          ];
        }
      ];
      users.users = lib.mkIf config.astahhu.common.is_server
        {
          btrbk.extraGroups = [ "wheel" ];
          root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPGx5yVTgRy/oXLuGvsK9PTr0hHbUCLz/+cKukb+L5K root@asta-backup" ];
        };
    }
    (lib.mkIf config.astahhu.common.disko.enable (import ./disko.nix {
      device = config.astahhu.common.disko.device;
      swap = config.astahhu.common.disko.swap;
    }))
  ];

}
