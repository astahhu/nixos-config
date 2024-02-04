{
  inputs = {
    nixpkgs.url = github:NixOs/nixpkgs;
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-contrib.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = github:nix-community/home-manager;
    #home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, stylix, hyprland-contrib, sops-nix, home-manager, ... }: {
    
    nixosConfigurations.Kakariko = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
        ./configuration.nix
        ./kakariko/hardware-configuration.nix
        ./kakariko/boot.nix
        home-manager.nixosModules.home-manager
      ];
      specialArgs = {inherit hyprland-contrib;};
    };

    nixosConfigurations.HyruleCity = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
        ./configuration.nix
        ./hyrule-city/hardware-configuration.nix
        ./hyrule-city/nvidia-config.nix
        ./hyrule-city/boot.nix
        ./hyrule-city/steam.nix
        home-manager.nixosModules.home-manager
      ];
      specialArgs = {inherit hyprland-contrib;};
    };
  };
}
