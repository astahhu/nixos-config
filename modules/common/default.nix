{pkgs, lib, config, modulesPath, ...}: {

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
  
  config = {
    myprograms = {
      cli.better-tools.enable = true;
    };

    nix-tun.storage.persist = lib.mkIf config.astahhu.common.is_server {
      enable = true;
      is_server = true;
    };

    services.openssh.enable = lib.mkIf config.astahhu.common.is_server true;
    security.pam.sshAgentAuth.enable = config.astahhu.common.is_server true;

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
    users.users.btrbk.extraGroups = lib.mkIf config.astahhu.common.is_server ["wheel"];
    users.users.root.openssh.authorizedKeys.keys = lib.mkIf config.astahhu.common.is_server ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPGx5yVTgRy/oXLuGvsK9PTr0hHbUCLz/+cKukb+L5K root@asta-backup"];
  } // (import ./disko.nix { 
    device = config.astahhu.common.disko.device;
    swap = config.astahhu.common.disko.swap;
  });

}
