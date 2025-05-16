{ pkgs, config, lib, ... }: {
  options = {
    astahhu.services.vaultwarden = {
      enable = lib.mkEnableOption "Enable vaultwarden on this server";
      domain = lib.mkOption {
        description = "The domain from which vaultwarden should be reached";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf config.astahhu.services.vaultwarden.enable {

    sops.secrets.vaultwarden-env = { };
    containers.vaultwarden = {
      bindMounts."${config.sops.secrets.vaultwarden-env.path}" = {
        hostPath = config.sops.secrets.vaultwarden-env.path;
      };
    };
    nix-tun.utils.containers.vaultwarden = {
      volumes = {
        "/var/lib/vaultwarden" = { };
      };
      domains = {
        vaultwarden = {
          domain = config.astahhu.services.vaultwarden.domain;
          port = 8000;
        };
      };
      config = { ... }: {
        boot.isContainer = true;


        services.vaultwarden = {
          enable = true;
          environmentFile = config.sops.secrets.vaultwarden-env.path;
        };
        networking.firewall.allowedTCPPorts = [ 8000 ];
      };
    };
  };
}
