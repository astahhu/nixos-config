{  config, pkgs, lib, ...} : {
  options = {
    astahhu.services.samba-fs = {
      enable = lib.mkEnableOption "Enable Samba Fileserver";
      shares = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule ({ ... } : { 
	  options = {
	    
	  };
	}));
	description = "Samba Shares";
	default = {};
      };
    };
  };

  config = {
   nix-tun.storage.persist.subvolumes = lib.attrsets.mapAttrs' (name: value: 
     {
       name = "/samba-shares/${name}";
       value.group = "1000512";
   }) // {
     samba = {
       bindMountDirectories = true;
       directories = "/var/lib/samba";
     };
   };

   services.samba = {
     enable = true;
     openFirewall = true;
     securityType = "ads";
     shares = lib.attrsets.mapAttrs (name: value: {
       path = "${config.nix-tun.storage.persist.path}/samba-fs/${name}";
       browesable = value.browesable;
       "read only" = "no";
       "administrative share" = "yes";
     }) config.astahhu.services.samba-fs.shares;

     extraConfig = ''
     workgroup = AD.ASTAHHU
     realm = as.astahhu.de
     winbind refresh tickets = true
     winbind use default domain = true
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
