{ config, lib, ... }: {
  config = lib.mkIf config.astahhu.common.is_server
    {


      nix-tun.storage.persist = lib.mkIf config.astahhu.common.uses_btrfs {
        enable = true;
        is_server = true;
      };

      services.openssh.enable = true;
      security.pam.sshAgentAuth.enable = true;

      services.btrbk.sshAccess = lib.mkIf config.astahhu.common.uses_btrfs [
        {
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPGx5yVTgRy/oXLuGvsK9PTr0hHbUCLz/+cKukb+L5K btrbk@asta-backup";
          roles = [
            "info"
            "source"
            "target"
          ];
        }
      ];
      users.users = lib.mkIf config.astahhu.common.uses_btrfs {
        btrbk.extraGroups = [ "wheel" ];
        root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPGx5yVTgRy/oXLuGvsK9PTr0hHbUCLz/+cKukb+L5K root@asta-backup" ];
      };
    };
}
