{ lib, config, ... }: {
  options.astahhu.common.is_lxc = lib.mkEnableOption "Set if this Server is an LXC, this will setup default configs";

  config = lib.mkIf config.astahhu.common.is_lxc {
    astahhu.common = {
      is_server = true;
      is_qemuvm = false;
      disko = {
        enable = false;
      };
    };


    systemd.settings.Manager = {
      LimitNOFILE = "8192:524288";
    };

    proxmoxLXC.enable = true;
    proxmoxLXC.manageHostName = true;

  };
}
