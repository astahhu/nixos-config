{ config, pkgs, ... }: 
{
  environment.systemPackages = with pkgs; [
    netcat
    curl
    bat
    lsd
    most
  ];

  programs.fish.enable=true;
  programs.fish.shellAliases= {
    ls = "lsd";
    tree = "lsd --tree";
    cat = "bat";
  };

  programs.starship.enable = true;
  programs.starship.settings = {
    character = {
      success_symbol = "➜";
      error_symbol = "➜";
    };
    
    nix_shell = {
      symbol = " ";
      heuristic = false;
    };
  };
}
