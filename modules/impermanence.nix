{ pkgs, config, lib, inputs, ... }: {

  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options = {
    jamesofscout.impermanence.enable = lib.mkEnableOption "Enable Impermanence - Delete Root on Every Boot";
    jamesofscout.impermanence.persistentFullHome = lib.mkEnableOption "Enable if simply all of Home should be Persistent";
    jamesofscout.impermanence.defaultPath = lib.mkOption {
      type = lib.types.str;
      description = "The Path where all default System Files are Stored";
    };
  };

  config = lib.mkIf config.jamesofscout.impermanence.enable {

    environment.persistence."${config.jamesofscout.impermanence.defaultPath}/system" = {
      hideMounts = true;
      directories = [
	"/var/log"
	"/var/lib/nixos" # For Correct User Mapping
	"/var/lib/systemd/coredump"
	# Color Profiles for Screens, Printers etc.
	{ directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
	(lib.mkIf config.jamesofscout.impermanence.persistentFullHome "/home")
	(lib.mkIf config.networking.networkmanager.enable "/var/lib/NetworkManager")
      ];
      files = [
      ];
    };

    services.openssh.hostKeys = [
      {
	bits = 4096;
	openSSHFormat = true;
	path = "${config.jamesofscout.impermanence.defaultPath}/system/etc/ssh/ssh_host_rsa_key";
	rounds = 100;
	type = "rsa";
      }
      {
	comment = "key comment";
	path = "${config.jamesofscout.impermanence.defaultPath}/system/etc/ssh/ssh_host_ed25519_key";
	rounds = 100;
	type = "ed25519";
      }
    ];
  };
}
