{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    nix-tun.url = "github:nix-tun/nixos-modules";
    nix-tun.inputs.nixpkgs.follows = "nixpkgs";
    wp4nix = {
      url = "github:helsinki-systems/wp4nix";
      flake = false;
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nix-topology.url = "github:oddlama/nix-topology";
    authentik-nix.url = "github:nix-community/authentik-nix";
  };

  outputs = {
    self,
    nixpkgs,
    sops-nix,
    ...
  } @ inputs:
    {
      nixosConfigurations.it-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (import ./hosts/it-laptop/disko.nix {device = "/dev/nvme0n1";})
          ./hosts/it-laptop/configuration.nix
          ./hosts/it-laptop/hardware-configuration.nix
          ./hosts/it-laptop/boot.nix
        ];
        specialArgs = {inherit inputs;};
      };

      nixosConfigurations.nix-nextcloud = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (import ./modules/common/disko.nix {device = "/dev/sda";})
          ./hosts/nix-nextcloud/configuration.nix
          ./modules/modules.nix
          ./users/admin-users.nix
	  ./modules/common/backup.nix
        ];
        specialArgs = {inherit inputs;};
      };

      nixosConfigurations.nix-wordpress = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (import ./modules/common/disko.nix {device = "/dev/sda";})
          ./hosts/nix-wordpress/configuration.nix
          ./modules/modules.nix
          ./users/admin-users.nix
	  ./modules/common/backup.nix
        ];
        specialArgs = {inherit inputs;};
      };

      nixosConfigurations.nix-samba-fs = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (import ./modules/common/disko.nix {device = "/dev/sda";})
          ./hosts/nix-samba-fs/configuration.nix
          ./modules/modules.nix
          ./users/admin-users.nix
	  ./modules/common/backup.nix
        ];
        specialArgs = {inherit inputs;};
      };

      nixosConfigurations.nix-authentik = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (import ./modules/common/disko.nix {device = "/dev/sda";})
          ./hosts/nix-authentik/configuration.nix
          ./modules/modules.nix
          ./users/admin-users.nix
	  ./modules/common/backup.nix
        ];
        specialArgs = {inherit inputs;};
      };

      nixosConfigurations.nix-wireguard = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nix-wireguard/configuration.nix
	  inputs.nixos-generators.nixosModules.all-formats
          ./modules/modules.nix
          ./users/admin-users.nix
        ];
        specialArgs = {inherit inputs;};
      };

      nixosConfigurations.nix-backup = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nix-backup/configuration.nix
          ./modules/modules.nix
        ];
        specialArgs = {inherit inputs;};
      };

      nixosConfigurations.stick = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
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
    }
    // inputs.flake-utils.lib.eachDefaultSystem (system: rec {
      pkgs = import nixpkgs {
        inherit system;
        overlays = [inputs.nix-topology.overlays.default];
      };

      topology = import inputs.nix-topology {
        inherit pkgs;
        modules = [
          # Your own file to define global topology. Works in principle like a nixos module but uses different options.
          ./topology.nix
          # Inline module to inform topology of your existing NixOS hosts.
          {nixosConfigurations = self.nixosConfigurations;}
        ];
      };
    });
}
