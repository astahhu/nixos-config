{
  
  inputs.nixpkgs.url = github:NixOs/nixpkgs;
  inputs.home-manager.url = github:nix-community/home-manager;

  outputs = { self, nixpkgs, ... }: {
    
    nixosConfigurations.Kakariko = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
