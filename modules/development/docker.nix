{ pkgs, config, lib, ... } : {

  options = {
    myprograms.development.docker.enable = lib.mkEnableOption "Enable Docker and Docker Compose and Stuff";
  };

  config = lib.mkIf config.myprograms.development.docker.enable {
    virtualisation.docker.enable = true;
    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };
}
