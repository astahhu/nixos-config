{
  config,
  lib,
  ...
}: let
  inherit
    (config.lib.topology)
    mkInternet
    mkRouter
    mkSwitch
    mkConnection
    ;
in {
  networks.internet = {
    name = "Internet";
  };
  networks.wireguard = {
    name = "Wireguard";
    style = {
      primaryColor = "#FF0000";
      secondaryColor = null;
      pattern = "dotted";
    };
  };
  networks.intern = {
    name = "AStA";
    cidrv4 = "134.99.154.0/24";
  };

  nodes.zim = {
    deviceType = "router";
    interfaces = {
      "eth0".network = "internet";
      "eth1" = {
        network = "intern";
        physicalConnections = [
          (mkConnection "server-01" "eth0")
          (mkConnection "server-02" "eth0")
        ];
      };
    };
  };

  nodes.server-01 = {
    deviceType = "cloud-server";
    interfaces = {
      "veth0" = {
        network = "intern";
        virtual = true;
      };
      "eth0" = {
        addresses = ["134.99.154.250"];
        network = "intern";
      };
    };
  };

  nodes.server-02 = {
    deviceType = "cloud-server";
    interfaces = {
      "veth0" = {
        network = "intern";
        virtual = true;
      };
      "eth0" = {
        network = "intern";
        addresses = ["134.99.154.251"];
      };
    };
  };

  nodes."asta-dc-v-01.asta2012" = {
    deviceType = "cloud-server";
    deviceIcon = ./icons/server-svgrepo-com.svg;
    parent = "server-01";
    guestType = "VM";
  };

  nodes."asta-datev-v-01.asta2012" = {
    deviceType = "cloud-server";
    deviceIcon = ./icons/server-svgrepo-com.svg;
    parent = "server-01";
    guestType = "VM";
  };

  nodes."samba-dc" = {
    deviceType = "cloud-server";
    deviceIcon = ./icons/server-svgrepo-com.svg;
    parent = "server-01";
    guestType = "VM";
  };

  nodes."samba-fs" = {
    deviceType = "cloud-server";
    deviceIcon = ./icons/server-svgrepo-com.svg;
    parent = "server-01";
    guestType = "VM";
  };

  nodes."asta-wgvpn-01.asta2012" = {
    deviceType = "cloud-server";
    deviceIcon = ./icons/server-svgrepo-com.svg;
    parent = "server-01";
    guestType = "VM";
    interfaces = {
      wg0 = {
        network = "wireguard";
        type = "wireguard";
      };
    };
  };

  nodes."asta-fs-v-02.asta2012" = {
    deviceType = "cloud-server";
    deviceIcon = ./icons/server-svgrepo-com.svg;
    parent = "server-02";
    guestType = "VM";
  };

  nodes."asta-datevbk-v-01.asta2012" = {
    deviceType = "cloud-server";
    deviceIcon = ./icons/server-svgrepo-com.svg;
    parent = "server-02";
    guestType = "VM";
  };

  nodes."asta-dc-v-02.asta2012" = {
    deviceType = "cloud-server";
    deviceIcon = ./icons/server-svgrepo-com.svg;
    parent = "server-02";
    guestType = "VM";
  };

  nodes."asta-ws03.asta2012" = {
    deviceType = "cloud-server";
    deviceIcon = ./icons/server-svgrepo-com.svg;
    parent = "server-02";
    guestType = "VM";
  };

  nodes."asta-ws01.asta2012" = {
    deviceType = "cloud-server";
    deviceIcon = ./icons/server-svgrepo-com.svg;
    parent = "server-02";
    guestType = "VM";
  };

  nodes."samba-dc-01" = {
    deviceType = "cloud-server";
    deviceIcon = ./icons/server-svgrepo-com.svg;
    parent = "server-02";
    guestType = "VM";
  };

  nodes.nix-samba-fs = {
    parent = "server-01";
    guestType = "VM";
  };

  nodes.nix-nextcloud = {
    parent = "server-02";
    guestType = "VM";
  };

  nodes.nix-wordpress = {
    parent = "server-02";
    guestType = "VM";
  };

  nodes.it-laptop = {
    deviceType = lib.mkForce "laptop";
    interfaces.wg0 = {
      network = "wireguard";
      type = "wireguard";
      physicalConnections = [(mkConnection "asta-wgvpn-01.asta2012" "wg0")];
    };
  };

  nodes.internet = mkInternet {
    connections = mkConnection "zim" "eth0";
  };
}
