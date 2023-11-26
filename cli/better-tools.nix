{ config, pkgs, ... }: 
{
  environment.systemPackages = with pkgs; [
    curl
    bat
    lsd
    most
    btop
    jq
    tmux
  ];

  programs.fish.enable=true;
  programs.fish.shellAliases= {
    ls = "lsd";
    tree = "lsd --tree";
    cat = "bat";
    gs = "git status";
    top = "btop";
    gl = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
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
