{ pkgs, config, lib, ... } : {
  options.astahhu.noreply-mail = {
    username = lib.mkOption {
      type = lib.types.str;
    };
    password_file = lib.mkOption {
      type = lib.types.str;
    };
    host = lib.mkOption {
      type = lib.types.str;
      description = ''
      The smtp server
      '';
    };
    email = lib.mkOption {
      type = lib.types.str;
      description = ''
      The email address of the user
      '';
    };
  };

  config = {
    sops.secrets = {
      noreply-mail-pw = {
	owner = "root";
	group = "mail";
      };

      noreply-mail-user = {
	owner = "root";
	group = "mail";
      };
    };

    programs.msmtp = { 
      enable = true;
      accounts.default = {
        host = "mail.astahhu.de";
	from = "";
	user = "";
	passwordEval = "cat ${}";
      };
    };
  };
}
