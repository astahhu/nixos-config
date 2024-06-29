{ config, pkgs, ... } : {


    sops.secrets.florian-pass = {
      neededForUsers = true;
    };

    users.users.florian = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets.florian-pass.path;
      extraGroups = ["wheel"];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqlr0nKMcn6rZE0hn8RyzfgT75IxKwzgPn59WH1TSdskJNwRJh5UEDKtHA3eSxguWVdJqSDtbDeO7D6pofqPxMarhCoQwa79056e2LtDYVrABTQPabRSTreHDbMekj6RsxdHAg2BFayutEVwHHRKBuyK3DQd5hu4P3DM9t3c5Zd4XEUY4wB0N2EYy56/kw7uUM49dCX10GLSFVivVyUmb3IpFLmOt7s5I64JpsU5NGG4VdrsRJlG2U2q8f3PWf8tIhqONtR+wa7AYOKKGmBBuq7I1qX3lE7+sgxUc9CFfHVC8+OLclnCizlJaiqXIN+K35URyrqxY5Wf7POeSfhewB florian@yubikey"
      ];
    };
}
