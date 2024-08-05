{
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
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
