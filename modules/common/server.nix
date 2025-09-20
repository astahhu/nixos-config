{ config, lib, ... }: {
  config = lib.mkIf config.astahhu.common.is_server
    {

      nix-tun.storage.persist = lib.mkIf config.astahhu.common.uses_btrfs {
        enable = true;
        is_server = true;
      };

      # Enable prometheus node-exporter metrics for the servers.
      # Will be reachable node-exporter.`${config.fqdnOrHostname}` on port 9100
      nix-tun.services = {
        traefik = {
          enable = lib.mkDefault true;
          enable_prometheus = lib.mkDefault true;
          letsencryptMail = lib.mkDefault "it@asta.hhu.de";
        };
      };
      nix-tun.alloy = lib.mkDefault {
        enable = true;
        loki-host = "loki.astahhu.de";
        prometheus-host = "prometheus.astahhu.de";
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

        btrbk = lib.mkIf config.astahhu.common.uses_btrfs {
          extraGroups = [ "wheel" ];
        };
        root.openssh.authorizedKeys.keys = [
          # Backup Server Key
          (lib.mkIf config.astahhu.common.uses_btrfs "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPGx5yVTgRy/oXLuGvsK9PTr0hHbUCLz/+cKukb+L5K asta-backup")
          # Build Server Key
          (lib.mkIf config.astahhu.common.is_server "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMzeIDT98aQrchzNu/k2oCpOfQO8xK96nL+OwxQl/BM+ nix-build")
        ];
      };
    };
}
