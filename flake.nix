{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    nixvim = {
      url = "github:nix-community/nixvim";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    nix-tun.url = "github:nix-tun/nixos-modules";
    flake-utils.url = "github:numtide/flake-utils";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    sops-nix,
    ...
  } @ inputs: {
    nixosConfigurations.it-laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.default
        (import ./hosts/it-laptop/disko.nix {device = "/dev/nvme0n1";})
        ./hosts/it-laptop/configuration.nix
        ./hosts/it-laptop/hardware-configuration.nix
        ./hosts/it-laptop/boot.nix
        inputs.home-manager.nixosModules.home-manager
      ];
      specialArgs = {inherit inputs;};
    };

    nixosConfigurations.nix-nextcloud = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nix-nextcloud/configuration.nix
        ./modules/modules.nix
        ./users/admin-users.nix
        inputs.home-manager.nixosModules.home-manager
      ];
      specialArgs = {inherit inputs;};
    };

    nixosConfigurations.nix-wordpress = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.default
        (import ./hosts/it-laptop/disko.nix {device = "/dev/sda";})
        ./hosts/nix-wordpress/configuration.nix
        ./modules/modules.nix
        ./users/admin-users.nix
        inputs.home-manager.nixosModules.home-manager
      ];
      specialArgs = {inherit inputs;};
    };

    nixosConfigurations.nix-samba-fs = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.default
        (import ./hosts/it-laptop/disko.nix {device = "/dev/sda";})
        ./hosts/nix-samba-fs/configuration.nix
        ./modules/modules.nix
        ./users/admin-users.nix
        inputs.home-manager.nixosModules.home-manager
      ];
      specialArgs = {inherit inputs;};
    };
    
    nixosConfigurations.stick = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
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
