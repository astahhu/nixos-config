{ pkgs, config, lib, inputs, ... }: {

  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.astahhu.impermanence = {
    enable = lib.mkEnableOption "Enable Impermanence - Delete Root on Every Boot";
    persistentFullHome = lib.mkEnableOption "Enable if simply all of Home should be Persistent";
    defaultPath = lib.mkOption {
      type = lib.types.str;
      description = "The Path where all default System Files are Stored";
    };
  };

  config = lib.mkIf config.astahhu.impermanence.enable {

    environment.persistence."${config.astahhu.impermanence.defaultPath}/system" = {
      hideMounts = true;
      directories = [
	"/var/log"
	"/var/lib/nixos" # For Correct User Mapping
	"/var/lib/systemd/coredump"
	# Color Profiles for Screens, Printers etc.
	{ directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
	(lib.mkIf config.astahhu.impermanence.persistentFullHome "/home")
	(lib.mkIf config.networking.networkmanager.enable "/etc/NetworkManager/system-connections")
	(lib.mkIf config.services.printing.enable "/var/lib/cups")
      ];
      files = [
      ];
    };

    services.openssh.hostKeys = [
      {
	bits = 4096;
	openSSHFormat = true;
	path = "${config.astahhu.impermanence.defaultPath}/system/etc/ssh/ssh_host_rsa_key";
	rounds = 100;
	type = "rsa";
      }
      {
	comment = "key comment";
	path = "${config.astahhu.impermanence.defaultPath}/system/etc/ssh/ssh_host_ed25519_key";
	rounds = 100;
	type = "ed25519";
      }
    ];
  };
}
