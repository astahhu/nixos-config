{ config, lib, ... }: {
  config = lib.mkIf config.astahhu.common.is_server
    {
      networking = {
        domain = "ad.astahhu.de";
        nameservers = [ "134.99.154.200" "134.99.154.201" ];
        defaultGateway = { address = "134.99.154.1"; interface = "eth0"; };
      };

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
      users.users = {
        btrbk.extraGroups = [ "wheel" ];
        root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPGx5yVTgRy/oXLuGvsK9PTr0hHbUCLz/+cKukb+L5K root@asta-backup" ];
      };
    };
}
