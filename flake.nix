{
  inputs = {
    nixpkgs.url = github:NixOs/nixpkgs;
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-contrib.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = github:nix-community/home-manager;
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
  }: {
    nixosConfigurations.Kakariko = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixvim.nixosModules.nixvim
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
        ./configuration.nix
        ./hosts/kakariko/hardware-configuration.nix
        ./hosts/kakariko/boot.nix
        home-manager.nixosModules.home-manager
      ];
      specialArgs = {inherit hyprland-contrib;};
    };

    nixosConfigurations.hateno = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixvim.nixosModules.nixvim
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
        ./hosts/hateno/configuration.nix
        ./cli/better-tools.nix
        ./hateno/hardware-configuration.nix
        ./hateno/boot.nix
      ];
      specialArgs = {inherit hyprland-contrib;};
    };

    nixosConfigurations.HyruleCity = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixvim.homeManagerModules.nixvim
        nixvim.nixosModules.nixvim
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
        ./configuration.nix
        ./hosts/hyrule-city/hardware-configuration.nix
        ./hosts/hyrule-city/nvidia-config.nix
        ./hosts/hyrule-city/boot.nix
        ./hosts/hyrule-city/steam.nix
        home-manager.nixosModules.home-manager
      ];
      specialArgs = {inherit hyprland-contrib;};
    };


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
