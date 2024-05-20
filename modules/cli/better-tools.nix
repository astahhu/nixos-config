{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
      inputs.nix-index-database.nixosModules.nix-index
  ];

  options = {
    myprograms.cli.better-tools.enable = lib.mkEnableOption "Enable my default CLI Setup which should exist on any Machine";
  };

  config = lib.mkMerge [(lib.mkIf config.myprograms.cli.better-tools.enable {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    
    environment.systemPackages = with pkgs; [
      curl
      nh
      nix-output-monitor
      bat
      lsd
      most
      btop
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
    programs.nix-index-database.comma.enable = true;

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
  })
  (lib.mkIf (!config.myprograms.cli.better-tools.enable) {
    programs.nix-index.enable = false;
    programs.nix-index.package = null;
  })];
}
