{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    calendar-join.url = "github:astahhu/calendar-join";
    home-manager.url = "github:nix-community/home-manager";
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
    devshell.url = "github:numtide/devshell";
    sops-nix.url = "github:Mic92/sops-nix";
    nix-tun.url = "github:nix-tun/nixos-modules";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-tun.inputs.nixpkgs.follows = "nixpkgs";
    wp4nix = {
      url = "github:helsinki-systems/wp4nix";
      flake = false;
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nix-topology.url = "github:oddlama/nix-topology";
    authentik-nix.url = "github:nix-community/authentik-nix";
  };

  outputs =
    inputs @ { ... }: inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      {
        imports = [
          inputs.nix-topology.flakeModule
        ];
        flake =
          {

            nixosConfigurations.it-laptop = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                (import ./hosts/it-laptop/disko.nix { device = "/dev/nvme0n1"; })
                ./hosts/it-laptop/configuration.nix
                ./hosts/it-laptop/hardware-configuration.nix
                ./hosts/it-laptop/boot.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nixosConfigurations.nix-nextcloud = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-nextcloud/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nixosConfigurations.nix-samba-fs = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-samba-fs/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nixosConfigurations.nix-samba-dc = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-samba-dc/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nixosConfigurations.nix-samba-dc-01 = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-samba-dc-01/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nixosConfigurations.nix-webserver = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-webserver/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nixosConfigurations.nix-wireguard = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-wireguard/configuration.nix
                ./modules
                ./users/admin-users.nix
                #inputs.nixos-generators.nixosModules.all-formats
              ];
              specialArgs = { inherit inputs; };
            };

            nixosConfigurations.nix-build = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-build/configuration.nix
                ./modules
                ./users/admin-users.nix
                #inputs.nixos-generators.nixosModules.all-formats
              ];
              specialArgs = { inherit inputs; };
            };


            nixosConfigurations.nix-backup = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-backup/configuration.nix
                ./modules
              ];
              specialArgs = { inherit inputs; };
            };

            deploy.nodes = {
              nix-samba-dc-01 = {
                hostname = "nix-samba-dc-01.ad.astahhu.de";
                profiles.system = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-samba-dc-01;
                  remoteBuild = true;
                  user = "root";
                };
              };

              nix-samba-dc = {
                hostname = "nix-samba-dc.ad.astahhu.de";
                profiles.system = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-samba-dc;
                  remoteBuild = true;
                  user = "root";
                };
              };

              nix-samba-fs = {
                hostname = "nix-samba-fs.ad.astahhu.de";
                profiles.system = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-samba-fs;
                  remoteBuild = true;
                  user = "root";
                };
              };

              nix-webserver = {
                hostname = "134.99.154.51";
                profiles.system = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-webserver;
                  remoteBuild = true;
                  user = "root";
                };
              };

              nix-nextcloud = {
                hostname = "nix-nextcloud.ad.astahhu.de";
                profiles.system = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-nextcloud;
                  remoteBuild = true;
                  user = "root";
                };
              };

              nix-wireguard = {
                hostname = "134.99.154.242";
                profiles.system = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-wireguard;
                  remoteBuild = true;
                  user = "root";
                };
              };

              nix-build = {
                hostname = "134.99.154.203";
                profiles.system = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-build;
                  remoteBuild = true;
                  user = "root";
                };
              };
            };


            checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib;

          };
        systems = [
          "x86_64-linux"
        ];
        perSystem = { system, ... }:
          let
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [ inputs.nix-topology.overlays.default ];
            };

          in
          {

            packages.default = inputs.self.topology.${system}.config.output;

            devShells.default =
              pkgs.mkShell {
                sopsPGPKeyDirs = [
                  "${toString ./.}/keys/hosts"
                  "${toString ./.}/keys/users"
                ];

                nativeBuildInputs = [
                  (pkgs.callPackage inputs.sops-nix { }).sops-import-keys-hook
                  pkgs.deploy-rs
                ];
              };

            formatter = pkgs.alejandra;

            topology.modules = [
              ./topology.nix
            ];
          };
      };
}
