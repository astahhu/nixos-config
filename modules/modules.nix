{
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.default
    inputs.nix-tun.nixosModules.nix-tun
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.nix-topology.nixosModules.default
    ./cli/better-tools.nix
    ./cli/nixvim.nix
    ./desktop/gnome.nix
    ./desktop/hyprland.nix
    ./desktop/programs.nix
    ./services/tailscale.nix
    ./services/wordpress.nix
    ./services/traefik.nix
    ./services/samba-share.nix
    ./development/vm.nix
    ./stylix.nix
  ];

  myprograms.stylix.enable = lib.mkDefault true;
  myprograms.cli.better-tools.enable = lib.mkDefault true;
}
