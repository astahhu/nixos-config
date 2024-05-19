{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    myprograms.cli.better-tools.enable = lib.mkEnableOption "Enable my default CLI Setup which should exist on any Machine";
  };

  config = {
    
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    
    environment.systemPackages = with pkgs; [
      curl
      nh
      nix-output-monitor
      bat
      lsd
      most
      btop
      jq
      tldr
      tmux
      duf
    ];

    programs.git.enable = true;

    users.defaultUserShell = pkgs.fish;
    programs.fish.enable = true;
    programs.fish.shellAliases = {
      ls = "lsd";
      tree = "lsd --tree";
      cat = "bat";
      gs = "git status";
      top = "btop";
      gl = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      vi = "nvim";
      vim = "nvim";
    };

    programs.tmux = {
      enable = true;
      clock24 = true;
    };

    programs.command-not-found.enable = false;
    programs.nix-index = {
      enable = true;
      enableFishIntegration = true;
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
  };
}
