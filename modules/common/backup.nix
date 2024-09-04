{ ... } : {
  services.btrbk.sshAccess = [{
    key = "sh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPGx5yVTgRy/oXLuGvsK9PTr0hHbUCLz/+cKukb+L5K btrbk@asta-backup";
    roles = [
      "info"
      "source" 
      "target"
    ];
  }];
  users.users.btrbk.extraGroups = [ "wheel" ];
}
