{ config, ... }: let 
inherit (config.lib.topology)
  mkInternet
  mkRouter
  mkSwitch
  mkConnection; in
{
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
      "eth0".network = "intern";
    };
  };

  nodes.server-02 = {
    deviceType = "cloud-server";
    interfaces = {
      "veth0" = {
        network = "intern";
	virtual = true;
      };
      "eth0".network = "intern";
    };
  };

  nodes.nix-nextcloud = {
    parent = "server-01";
    guestType = "VM";
  };

  nodes.nix-wordpress = {
    parent = "server-02";
    guestType = "VM";
  };
  
  nodes.nix-samba-fs = {
    parent = "server-02";
    guestType = "VM";
  };

  nodes.it-laptop.interfaces.wg0 = {
    network = "wireguard";
    type = "wireguard";
  };
  
  nodes.internet = mkInternet {
    connections = mkConnection "zim" "eth0";
  };
}
