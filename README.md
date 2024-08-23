# These are NixOs Configuration for AStA Servers
These are the current Hosts:

- __nix-nextcloud__ - Nextcloud Instance for AStA
- __nix-wordpress__ - Worpress Hosts for AStA 

## GOALS for Recovery/Deployment:
To Recover a Machine from a failed State, only the explicit Persistend Data and the Current Configuration should be Needed. 

All System Upgrades should happpen in these two Steps:

1. Snapshot the Current State by Snapshoting each persistent Directory.
2. Upgrade the Current System

## Modules

## Setup an additional Server
To deploy a new Server, do the following Steps:

1. Copy the contents of hosts/sample-server folder, for a new host
2. Add the following lines to `flake.nix`, inside the outputs section:
```nix
    nixosConfigurations.nix-sample-server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ### CHANGE ME
        ./hosts/nix-sample-server/configuration.nix


        (import ./modules/common/disko.nix {device = "/dev/sda";})
        ./modules/modules.nix
        ./users/admin-users.nix

      ];
      specialArgs = {inherit inputs;};
    };
```
3. Push your Changes to github (Maybe on a new Branch)
4. Execute the following Commands on the Server:

```bash
git clone https://github.com/astahhu/nixos-config.git
# Change /dev/sda to the main boot disk
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./nixos-config/modules/common/disko.nix --arg device '"/dev/sda"'
nixos-install --flake ./nixos-config#HOSTNAME

```

## TODOS:
Setup Impermanence for all Systems.

- [ ] nix-wordpress
- [ ] nix-nextcloud
