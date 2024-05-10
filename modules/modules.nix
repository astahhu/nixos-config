{...}: {
  imports = [
    ./cli/better-tools.nix
    ./cli/nixvim.nix
    ./desktop/gnome.nix
    ./desktop/hyprland.nix
    ./desktop/programs.nix
    ./services/tailscale.nix
    ./stylix.nix
  ];

  myprograms.stylix.enable = true;
}
