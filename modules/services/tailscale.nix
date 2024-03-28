{
  config,
  pkgs,
  lib,
  ...
}: {

  options = {
    myservices.tailscale.enable = lib.mkEnableOption "Enable Tailscale";
  };

  config = lib.mkIf config.myservices.tailscale.enable {
    # always allow traffic from your Tailscale network
    networking.firewall.trustedInterfaces = ["tailscale0"];

    # allow the Tailscale UDP port through the firewall
    networking.firewall.allowedUDPPorts = [config.services.tailscale.port];

    # make the tailscale command usable to users
    environment.systemPackages = [pkgs.tailscale];

    sops.secrets.tailscale-auth = {
      format = "yaml";
      sopsFile = ../../secrets/tailscale.yaml;
    };

    # enable the tailscale service
    services.tailscale.enable = true;

    # create a oneshot job to authenticate to Tailscale
    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = ["network-pre.target" "tailscale.service"];
      wants = ["network-pre.target" "tailscale.service"];
      wantedBy = ["multi-user.target"];

      # set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # have the job run this shell script
      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2
        
        # otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up --authkey file:${config.sops.secrets.tailscale-auth.path} --accept-routes --operator=florian
      '';
    };
  };
}
