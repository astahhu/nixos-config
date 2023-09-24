{
  
  inputs.nixpkgs.url = github:NixOs/nixpkgs;
  inputs.hyprland-contrib.url = "github:hyprwm/contrib";
  inputs.home-manager.url = github:nix-community/home-manager;
  inputs.stylix.url = "github:danth/stylix";

  outputs = { self, nixpkgs, stylix, hyprland-contrib,... }: {
    
    nixosConfigurations.Kakariko = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ stylix.nixosModules.stylix ./configuration.nix ];
      specialArgs = {inherit hyprland-contrib;};
    };
  };
}
