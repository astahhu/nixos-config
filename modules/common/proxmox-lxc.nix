{ lib, ... }: {
  options.astahhu.common.is_lxc = lib.mkEnableOption "Set if this Server is an LXC, this will setup default configs";

  config = {
    astahhu.common = {
      is_server = true;
      is_qemuvm = false;
      disko = {
        enable = false;
      };
    };

  };
}
