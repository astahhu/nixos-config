# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{pkgs, config, ...}: {
  imports = [
    ../../modules/modules.nix
    ./hardware-configuration.nix
  ];



  # Change for each System
  networking.hostName = "nix-wireguard";

  # Uncomment if you need Secrets for this Hosts, AFTER the first install  
  sops.defaultSopsFile = ../../secrets/nix-wireguard.yaml;
  sops.secrets.wireguard_private = {};

  networking.nat.enable = true;
  networking.nat.externalInterface = "ens192";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "10.105.42.1/24" ];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = 51820;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.105.42.0/24 -o ens192 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.105.42.0/24 -o ens192 -j MASQUERADE
      '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "${config.sops.secrets.wireguard_private.path}";

      peers = [
        # List of allowed peers.
        { # Feel free to give a meaning full name
          # Public key of the peer (not a file path).
	  name = "2";
          publicKey = "qAzWfOAMP3w4vusIyjyHFl7aTLG7eZrCz20bE6PkVik=";
          # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
          allowedIPs = [ "10.105.42.2/32" ];
        }
        {
	  name = "3";
          publicKey = "X7SwpnOfNBFyXo5ELD7Jfd4psSu/WiF6ucyNP+zvrww=";
          allowedIPs = [ "10.105.42.3/32" ];
        }
        {
	  name = "4";
          publicKey = "/+DAqTxrCYqicFmJ3hGPc4++BwBbkni7MH5BNOKuinc=";
          allowedIPs = [ "10.105.42.4/32" ];
        }
        {
	  name = "5";
          publicKey = "Xt92xMbkfhiB63Yig3caZuPs7geA53LdCwFwCZjR/y0=";
          allowedIPs = [ "10.105.42.5/32" ];
	  endpoint = "134.99.39.12:60538";
        }
        {
	  name = "6";
          publicKey = "Cxjqdj+sbnz1reh0INfylzyhkm18zjWgg3P6BOC+DW0=";
          allowedIPs = [ "10.105.42.6/32" ];
        }
        {
	  name = "7";
          publicKey = "uOKm/Gdqn7dGMYlzYuVB9LP2U2peLP6qqHP8neUNwEU=";
          allowedIPs = [ "10.105.42.7/32" ];
        }
        {
	  name = "8";
          publicKey = "zsqHwvlfiPVuPMVKoIeN1h0CE5ts9H/numnOIrNJZlk=";
          allowedIPs = [ "10.105.42.8/32" ];
        }
        {
	  name = "9";
          publicKey = "1FmBk72xRgoFxSBaeaxeHWBzlk+mKFAUzDnUUiGpKUo=";
          allowedIPs = [ "10.105.42.9/32" ];
        }
        {
	  name = "10";
          publicKey = "KdimHNVz4OmMlc+ZUz06ntBLdB6fw+lC4RmdWXDt00U=";
          allowedIPs = [ "10.105.42.10/32" ];
        }
        {
	  name = "11";
          publicKey = "t0hmDrrymNCcmkcaBpfEUWUBdJ2sOdexHFjwbJzIMHo=";
          allowedIPs = [ "10.105.42.11/32" ];
        }       
	{
	  name = "12";
          publicKey = "mLZAKxex044RCUbIAiOC8LdlHyYvp+CVeciHRLZLDgE=";
          allowedIPs = [ "10.105.42.12/32" ];
        }
        {
	  name = "13";
          publicKey = "hC4d0h2ewwWFdHeKBRGJupR1Qm1pSv832rkv8K4xpgA=";
          allowedIPs = [ "10.105.42.13/32" ];
        }
        {
	  name = "14";
          publicKey = "4OV6hnXsTDdmF0hj0IyAyPg9fwJAOhqHEv04A9ZiFlQ=";
          allowedIPs = [ "10.105.42.14/32" ];
        }
        {
	  name = "15";
          publicKey = "LOJoxvbNiRZ3/EAd10kPolzcGb2VeMf1lAVTeiMriyU=";
          allowedIPs = [ "10.105.42.15/32" ];
        }
	{
	  name = "16";
          publicKey = "TTWhoxuCOJryuTfMcQ+7mWxpbYtOngfyqbK0LCF+qE0=";
          allowedIPs = [ "10.105.42.16/32" ];
        }
        {
	  name = "17";
          publicKey = "GMzQnVABjufZQ6Czm6D+X85C5qr9Y2FYF3fWMg313QM=";
          allowedIPs = [ "10.105.42.17/32" ];
        }
        {
	  name = "18";
          publicKey = "zZIOUcr6TTISKLSe0RzFpWyghKGD0PTsr5WlcRBl3xQ=";
          allowedIPs = [ "10.105.42.18/32" ];
        }
        {
	  name = "19";
          publicKey = "mNeA/lJCOVO78BxPiXhwbBjLAZwQ90NNMPDdf1Z3v24=";
          allowedIPs = [ "10.105.42.19/32" ];
        }
        {
	  name = "20";
          publicKey = "nJBfaylAfoTZjYco5ZgJusm60XOBCKzFeK30yY3e41k=";
          allowedIPs = [ "10.105.42.20/32" ];
        }
        {
	  name = "21";
          publicKey = "/hTh57oidbhGEWViahL4dxhCLxXQ/q0I8MIlZ7go/1E=";
          allowedIPs = [ "10.105.42.21/32" ];
        }
        {
	  name = "22";
          publicKey = "2ytpT/rSMOv0xpukKm5BL1ipDyv9MG8wqwxLG0790yE=";
          allowedIPs = [ "10.105.42.22/32" ];
        }
        {
	  name = "23";
          publicKey = "L235h97SbeoYKE25VzkJp7uilmQ3VJzGLZrr3SKbIHg=";
          allowedIPs = [ "10.105.42.23/32" ];
        }
        {
	  name = "24";
          publicKey = "ri3E91KHp15VrgdVSdHBQimb97DEQuDu8SiQ3SODB1I=";
          allowedIPs = [ "10.105.42.24/32" ];
        }
      ];
    };
  };

  # Networking
  networking.firewall.enable = true;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.10"; # Did you read the comment?

  # Enable VMWare Guest
  virtualisation.vmware.guest.enable = true;
  # Enable the Persist Storage Module
  nix-tun.storage.persist = {
    enable = true;
    is_server = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  security.pam.sshAgentAuth.enable = true;

  myprograms.cli.better-tools.enable = true;

  nixpkgs.config.allowUnfree = true;
}
