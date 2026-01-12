{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  options.astahhu.services.calendar-join = {
    enable = lib.mkEnableOption "Whether to Enable the Calendar Join Tool";
    calendars = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      description = ''
        The Calendars that the Server should combine under Name.
      '';
      example = {
        joined1 = {
          single1 = "https://nextcloud.example.com/remote.php/dav/public-calendars/CAx5MEp7cGrQ6cEe?export";
          single2 = "https://nextcloud.example.com/remote.php/dav/public-calendars/tfooczYRNeoLjKJB?export";
        };
      };
    };

  };
  config = lib.mkIf config.astahhu.services.calendar-join.enable {
    nix-tun.services.traefik.services.calendar-join = {
      router.rule = "Host(`calendar.astahhu.de`)";
      router.tls.enable = false;
      servers = [ "http://localhost:8080" ];
    };

    systemd.services.calendar-join = {
      description = "Serves the Calendar join tool";
      after = [ "network.target" ];
      serviceConfig = {
        RestartSec = 5;
        Restart = "always";
        #User = "calendar-join";
        Type = "exec";
        ExecStart = "${
          inputs.calendar-join.packages."${pkgs.stdenv.hostPlatform.system}".default
        }/bin/calendar-join --config ${builtins.toFile "calendar-config.json" (builtins.toJSON config.astahhu.services.calendar-join.calendars)}";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
