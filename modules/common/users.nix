
{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    astahhu.common.admin-users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({...}: {
        options = {
          sshKeys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Public SSH keys for the user";
          };
          setPassword = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to set the password via sops.";
          };
        };
      }));
      default = {};
    };
  };

  config = {
    sops.secrets =
      lib.attrsets.mapAttrs' (name: value: {
        name = "${name}-pass";
        value = {
          neededForUsers = true;
        };
      })
      (lib.attrsets.filterAttrs (name: value: value.setPassword) config.astahhu.common.admin-users);

    users.users =
      lib.attrsets.mapAttrs (name: value: {
        isNormalUser = true;
        hashedPasswordFile = lib.mkIf value.setPassword config.sops.secrets.florian-pass.path;
        extraGroups = [
          "wheel"
          (lib.mkIf config.virtualisation.docker.enable "docker")
          (lib.mkIf config.networking.networkmanager.enable "networkmanager")
          (lib.mkIf config.astahhu.development.vm.enable "libvirtd")
        ];
        shell = pkgs.fish;
        openssh.authorizedKeys.keys = value.sshKeys;
      })
      config.astahhu.common.admin-users;
  };
}
