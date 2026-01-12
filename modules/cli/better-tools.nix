{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];

  options = {
    astahhu.cli.better-tools.enable = lib.mkEnableOption "Enable my default CLI Setup which should exist on any Machine";
  };

  config = lib.mkMerge [
    (lib.mkIf config.astahhu.cli.better-tools.enable {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      environment.systemPackages = with pkgs; [
        dig
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

      astahhu.cli.nixvim.enable = true;

      programs.git.enable = true;
      programs.direnv = {
        enable = true;
        silent = true;
      };
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
      #programs.nix-index = {
      #  enable = true;
      #  enableFishIntegration = true;
      #};

      nix.registry = {
        nixpkgs.to = {
          type = "path";
          path = pkgs.path;
        };
      };

      #programs.nix-index-database.comma.enable = true;

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
    (lib.mkIf (!config.astahhu.cli.better-tools.enable) {
      programs.nix-index.enable = false;
      programs.nix-index.package = null;
    })
  ];
}
