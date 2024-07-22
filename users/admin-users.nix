{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    astahhu.admin-users = lib.mkOption {
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
    astahhu.admin-users.florian.sshKeys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqlr0nKMcn6rZE0hn8RyzfgT75IxKwzgPn59WH1TSdskJNwRJh5UEDKtHA3eSxguWVdJqSDtbDeO7D6pofqPxMarhCoQwa79056e2LtDYVrABTQPabRSTreHDbMekj6RsxdHAg2BFayutEVwHHRKBuyK3DQd5hu4P3DM9t3c5Zd4XEUY4wB0N2EYy56/kw7uUM49dCX10GLSFVivVyUmb3IpFLmOt7s5I64JpsU5NGG4VdrsRJlG2U2q8f3PWf8tIhqONtR+wa7AYOKKGmBBuq7I1qX3lE7+sgxUc9CFfHVC8+OLclnCizlJaiqXIN+K35URyrqxY5Wf7POeSfhewB florian@yubikey"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDF5vhkEdRPrHHLgCMxm0oSrHU+uPM9W45Kdd/BKGreRp5vAA70vG3xEjzGdzIlhF0/qOZisA3MpjnMhW3l+uogTzuD3vDZdgT/pgoZEy2CIGIp9kbK5pQHhEhMbWi5NS5o8F095ZZRjBwRE1le9GmBZbYj3VUHSVaRxv+gZpSdqKBo9Arvr4L/lyTdpYgGEHUParWX+UtkBXSd0mO91h6XM8hEqLJv+ufbgA4az0O8sNTz2Uh+k3kN2sQn11O3ekGk4M9fpDP9+C17C9fbMpMATbFazl5pWnPqgLPrvNCs8dkKEJCRPgTgXHYaOppZ7hprJvMpOYW/IYyYo/1T2j6ELZJ7apMJNlOhWqVDnM5DGSIf65oNGZLiAupq1X+s6IoSEZOcAuWfTlJgRySdNgh/BSiKvmKG0nK8/z2ERN0/shE9/FT7pMyEfxHzNdl4PMvpPKZkucX1z4Pb3DtR684WRxD94lj5Nqh/3CH0EeLMJPwyFsOBNdsitqZGLHpGbOLZ3VDdjbOl2Qjgyl/VwzhAWNYUpyxZj3ZpFlHyDE0y38idXG7L0679THKzE62ZAnPdHHTP5RdWtRUqpPyO/nVXErOr8j55oO27C6jD0n5L4tU3QgSpjMOvomk9hbPzKEEuDGG++gSj9JoVHyAMtkWiYuamxR1UY1PlYBskC/q77Q== openpgp:0xB802445D"
    ];

    sops.secrets =
      lib.attrsets.mapAttrs' (name: value: {
        name = "${name}-pass";
        value = {
          neededForUsers = true;
        };
      })
      (lib.attrsets.filterAttrs (name: value: value.setPassword) config.astahhu.admin-users);

    users.users =
      lib.attrsets.mapAttrs (name: value: {
        isNormalUser = true;
        hashedPasswordFile = lib.mkIf value.setPassword config.sops.secrets.florian-pass.path;
        extraGroups = [
          "wheel"
          "input"
          "uinput"
          (lib.mkIf config.virtualisation.docker.enable "docker")
          (lib.mkIf config.networking.networkmanager.enable "networkmanager")
          (lib.mkIf config.astahhu.development.vm.enable "libvirtd")
        ];
        shell = pkgs.fish;
        openssh.authorizedKeys.keys = value.sshKeys;
      })
      config.astahhu.admin-users;
  };
}
