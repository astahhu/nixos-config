{
  
  inputs.nixpkgs.url = github:NixOs/nixpkgs;
  inputs.hyprland-contrib.url = "github:hyprwm/contrib";
  inputs.home-manager.url = github:nix-community/home-manager;

  outputs = { self, nixpkgs, hyprland-contrib,... }: {
    
    nixosConfigurations.Kakariko = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
      specialArgs = {inherit hyprland-contrib;};
    };
  };
}
