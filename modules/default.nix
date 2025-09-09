{ lib
, inputs
, ...
}: {
  imports = [
    inputs.disko.nixosModules.default
    inputs.nix-tun.nixosModules.nix-tun
    inputs.home-manager.nixosModules.home-manager
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
    ./services/matrix.nix
    ./services/wordpress.nix
    ./services/samba
    ./services/cinny.nix
    ./services/vaultwarden.nix
    ./services/postgres.nix
    ./services/ntfy.nix
    ./development/vm.nix
    ./stylix.nix
  ];

  myprograms.stylix.enable = lib.mkDefault true;
  astahhu.cli.better-tools.enable = lib.mkDefault true;
}
