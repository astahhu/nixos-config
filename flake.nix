{
  inputs = {
    nixpkgs.url = github:NixOs/nixpkgs;
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-contrib.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = github:nix-community/home-manager;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, stylix, hyprland-contrib, sops-nix,... }: {
    
    nixosConfigurations.Kakariko = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        stylix.nixosModules.stylix
        ./configuration.nix
        ./kakariko-hardware-configuration.nix
        sops-nix.nixosModules.sops
      ];
      specialArgs = {inherit hyprland-contrib;};
    };

    nixosConfigurations.HyruleCity = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        stylix.nixosModules.stylix
        ./configuration.nix
        ./hyrule-city-hardware-configuration.nix
        sops-nix.nixosModules.sops
      ];
      specialArgs = {inherit hyprland-contrib;};
    };
  };
}
