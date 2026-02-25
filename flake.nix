{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    calendar-join.url = "github:astahhu/calendar-join";
    home-manager.url = "github:nix-community/home-manager";
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
    devshell.url = "github:numtide/devshell";
    sops-nix.url = "github:Mic92/sops-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
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
    grafana2ntfy.url = "github:fscs/grafana-to-ntfy";
    grafana2ntfy.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ ... }:
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      {
        imports = [
          inputs.nix-topology.flakeModule
        ];
        flake = {

          nixosConfigurations = {
            nix-nextcloud = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-nextcloud/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nix-postgresql = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-postgresql/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nix-samba-fs = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-samba-fs/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nix-samba-dc = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-samba-dc/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nix-samba-dc-01 = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-samba-dc-01/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nix-webserver = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-webserver/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nix-wireguard = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-wireguard/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nix-build = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-build/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nix-asta2012-dc = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-asta2012-dc/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nix-asta2012-dc-01 = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-asta2012-dc-01/configuration.nix
                ./modules
                ./users/admin-users.nix
              ];
              specialArgs = { inherit inputs; };
            };

            nix-backup = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/nix-backup/configuration.nix
                ./modules
              ];
              specialArgs = { inherit inputs; };
            };
          };

          deploy = {
            profilesOrder = [
              "samba"
              "system"
            ];
            nodes = {
              nix-samba-dc-01 = {
                hostname = "nix-samba-dc-01.ad.astahhu.de";
                profiles.samba = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-samba-dc-01;
                  user = "root";
                  confirmTimeout = 300;
                  activationTimeout = 600;
                };
              };

              nix-asta2012-dc = {
                hostname = "134.99.154.226";
                profiles.samba2012 = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-asta2012-dc;
                  user = "root";
                  confirmTimeout = 180;
                  activationTimeout = 600;
                };
              };

              nix-asta2012dc1 = {
                hostname = "134.99.154.228";
                profiles.samba2012 = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-asta2012-dc-01;
                  user = "root";
                  confirmTimeout = 180;
                  activationTimeout = 600;
                };
              };

              nix-samba-dc = {
                hostname = "nix-samba-dc.ad.astahhu.de";
                profiles.samba = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-samba-dc;
                  user = "root";
                  confirmTimeout = 300;
                  activationTimeout = 600;
                };
              };

              nix-samba-fs = {
                hostname = "nix-samba-fs.ad.astahhu.de";
                profiles.samba = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-samba-fs;
                  user = "root";
                  confirmTimeout = 300;
                  activationTimeout = 600;
                };
              };

              nix-postgresql = {
                hostname = "134.99.154.212";
                profiles.system = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-postgresql;
                  user = "root";
                  confirmTimeout = 180;
                  activationTimeout = 600;
                };
              };
              nix-webserver = {
                hostname = "134.99.154.51";
                profiles.system = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-webserver;
                  user = "root";
                  confirmTimeout = 180;
                  activationTimeout = 600;
                };
              };

              nix-nextcloud = {
                hostname = "nix-nextcloud.ad.astahhu.de";
                profiles.system = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-nextcloud;
                  user = "root";
                  # Nextcloud should never rollback
                  autoRollback = false;
                  confirmTimeout = 180;
                  activationTimeout = 600;
                };
              };

              nix-wireguard = {
                hostname = "134.99.154.207";
                profiles.system = {
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.nix-wireguard;
                  user = "root";
                  confirmTimeout = 180;
                  autoRollback = false;
                  activationTimeout = 600;
                };
              };
            };
          };

          checks = builtins.mapAttrs (
            system: deployLib: deployLib.deployChecks inputs.self.deploy
          ) inputs.deploy-rs.lib;

        };
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        perSystem =
          { system, ... }:
          let
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [ inputs.nix-topology.overlays.default ];
            };

          in
          {

            packages.default = inputs.self.topology.${system}.config.output;

            devShells.default = pkgs.mkShell {
              sopsPGPKeyDirs = [
                "${toString ./.}/keys/hosts"
                "${toString ./.}/keys/users"
              ];

              nativeBuildInputs = [
                (pkgs.callPackage inputs.sops-nix { }).sops-import-keys-hook
                pkgs.deploy-rs
                pkgs.pinentry-curses
              ];
            };

            formatter = pkgs.nixfmt-rfc-style;

            topology.modules = [
              ./topology.nix
            ];
          };
      };
}
