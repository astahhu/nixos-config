{ lib
, inputs
, ...
}: {
  imports = [
    inputs.disko.nixosModules.default
    inputs.nix-tun.nixosModules.nix-tun
    inputs.home-manager.nixosModules.home-manager
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
    ./services/samba
    ./services/vaultwarden.nix
    ./services/ntfy.nix
    ./development/vm.nix
    ./stylix.nix
  ];

  myprograms.stylix.enable = lib.mkDefault true;
  astahhu.cli.better-tools.enable = lib.mkDefault true;
}
