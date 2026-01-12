{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    jamesofscout.yubikey-gpg.enable = lib.mkEnableOption "Enable Yubikey and GPG Support";
  };

  config = lib.mkIf config.jamesofscout.yubikey-gpg.enable {
    # Smartcard Support
    services.pcscd.enable = true;

    environment.systemPackages = with pkgs; [
      yubikey-personalization
      gnupg
    ];
    services.udev.packages = with pkgs; [
      yubikey-personalization
    ];

    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';

    programs.gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-curses;
      enableSSHSupport = true;
    };
    ## Fix for GnuPG and PCSC colnflict
    home-manager.sharedModules = [
      {
        home.file.".gnupg/scdaemon.conf".text = ''
          disable-ccid
        '';
      }
    ];

    # Use GPG Keys instead of SSH Keys
    programs.ssh.startAgent = lib.mkIf config.services.openssh.enable false;
    environment.shellInit = lib.mkIf config.services.openssh.enable ''
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      echo UPDATESTARTUPTTY | gpg-connect-agent
    '';
  };
}
