{
  pkgs,
  config,
  nixvim,
  system,
  lib,
  ...
}: {
  options = {
    myprograms.cli.nixvim.enable = lib.mkEnableOption "Enable nixvim";
  };

  config = lib.mkIf config.myprograms.cli.nixvim.enable {
    programs.nixvim.enable = true;
  };
}
