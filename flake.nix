{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs";
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-contrib.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    #home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    stylix,
    hyprland-contrib,
    sops-nix,
    home-manager,
    flake-utils,
    nixvim,
    ...
  } @ inputs: {
    nixosConfigurations.Kakariko = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
        ./configuration.nix
        ./hosts/kakariko/hardware-configuration.nix
        ./hosts/kakariko/boot.nix
        home-manager.nixosModules.home-manager
	inputs.nix-index-database.nixosModules.nix-index
      ];
      specialArgs = {inherit inputs;};
    };

    nixosConfigurations.Hateno = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
        inputs.nix-index-database.nixosModules.nix-index
	./hosts/hateno/configuration.nix
        ./hosts/hateno/hardware-configuration.nix
        ./hosts/hateno/boot.nix
      ];
      specialArgs = {inherit inputs;};
    };

    nixosConfigurations.HyruleCity = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
	inputs.nix-index-database.nixosModules.nix-index
        ./configuration.nix
        ./hosts/hyrule-city/hardware-configuration.nix
        ./hosts/hyrule-city/nvidia-config.nix
        ./hosts/hyrule-city/boot.nix
        ./hosts/hyrule-city/steam.nix
        home-manager.nixosModules.home-manager
      ];
      specialArgs = {inherit inputs;};
    };

    stick = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
	./hosts/stick/configuration.nix
	./modules/modules.nix
      ];
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    devShells."x86_64-linux".default = with import nixpkgs {system = "x86_64-linux";};
      mkShell {
        sopsPGPKeyDirs = [
          "${toString ./.}/keys/hosts"
          "${toString ./.}/keys/users"
        ];

        nativeBuildInputs = [
          (pkgs.callPackage sops-nix {}).sops-import-keys-hook
        ];
      };
  };
}
