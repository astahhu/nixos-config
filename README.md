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


## TODOS:
Setup Impermanence for all Systems.

- [ ] nix-wordpress
- [ ] nix-nextcloud
