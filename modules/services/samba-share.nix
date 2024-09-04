{  config, pkgs, lib, ...} : {
  options = {
    astahhu.services.samba-fs = {
      enable = lib.mkEnableOption "Enable Samba Fileserver";
      shares = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule ({ ... } : { 
	  options = {
	    browseable = lib.mkOption {
	      type = lib.types.str;
	    };
	  };
	}));
	description = "Samba Shares";
	default = {};
      };
    };
  };

  config = lib.mkIf config.astahhu.services.samba-fs.enable {
   nix-tun.storage.persist.subvolumes = lib.attrsets.mapAttrs' (name: value: 
     {
       name = "samba-shares/${name}";
       value.group = "1000512";
   }) config.astahhu.services.samba-fs.shares // {
     samba = {
       bindMountDirectories = true;
       directories = {
	"/var/lib/samba" = {};
	"/var/lib/samba/private" = {};
	"/var/lock/samba" = {};
       };
     };
   };

   security.pam.krb5.enable = false;
   security.krb5 = {
     enable = true;
     settings = {
       libdefaults = {
         default_realm = "ad.astahhu.de";
	 dns_lookup_realm = false;
	 dns_lookup_kdc = true;
       };
       localauth = {
         module = "winbind:${config.services.samba.package}/lib/samba/krb5/winbind_krb5_localauth.so";
         enable_only = "winbind";
       };
     };
   };

   services.samba-wsdd = {
     enable = true;
     openFirewall = true;
   };

   services.samba = {
    enable = true;
     package = pkgs.samba4Full;
     openFirewall = true;
     securityType = "ads";
     nsswins = true;
     shares = lib.attrsets.mapAttrs (name: value: {
       path = "${config.nix-tun.storage.persist.path}/samba-shares/${name}";
       browseable = value.browseable;
       "read only" = "no";
       "administrative share" = "yes";
       "vfs objects" = "btrfs shadow_copy2";
       "shadow:snapdir" = "${config.nix-tun.storage.persist.path}/samba-shares/${name}/.snapshots";
       "shadow:basedir" = "${config.nix-tun.storage.persist.path}/samba-shares/${name}";
       "shadow:sort" = "desc";
       "shadow:format" = "${name}.%Y%m%dT%H%M%S%z";
    }) config.astahhu.services.samba-fs.shares;

     extraConfig = ''
     allow trusted domains = yes
     workgroup = AD.ASTAHHU
     realm = ad.astahhu.de
     netbios name = NIX-SAMBA-FS
     winbind refresh tickets = true
     template shell = ${pkgs.bash}
     idmap config * : range = 100000 - 199999
     idmap config AD.ASTAHHU : backend = rid
     idmap config AD.ASTAHHU : range = 1000000 - 1999999
     idmap config ASTA2012 : backend = rid
     idmap config ASTA2012 : range = 2000000 - 2999999
     inherit acls = yes
     vfs objects = acl_xattr
     '';
    };
  };
}
