{ pkgs, modulesPath, ...} : {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  environment.systemPackages = [
    pkgs.btrfs-progs
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;
  myprograms.cli = {
    better-tools.enable = true;
    nixvim.enable = true;
  };
}
