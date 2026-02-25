{
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.default
    inputs.nixos-generators.nixosModules.all-formats
    inputs.sops-nix.nixosModules.sops
    inputs.nix-topology.nixosModules.default
    ./services/calendar-join.nix
    ./common
    ./cli/better-tools.nix
    ./cli/nixvim.nix
    ./desktop/gnome.nix
    ./desktop/hyprland.nix
    ./desktop/programs.nix
    ./services/tailscale.nix
    ./services/wordpress.nix
    ./services/keycloak.nix
    ./services/samba
    ./services/vaultwarden.nix
    ./services/postgres.nix
    ./services/ntfy.nix
    ./development/vm.nix
    ./nix-tun
  ];

  astahhu.cli.better-tools.enable = lib.mkDefault true;
}
