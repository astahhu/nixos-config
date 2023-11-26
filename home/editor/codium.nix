{ pkgs, ...} : {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
      jnoortheen.nix-ide
      redhat.vscode-xml
    ];
    userSettings = {
      "editor.fontLigatures" = true;
      "git.confirmSync" = false;
      "terminal.integrated.fontLigatures" = true;
      "[xml]"= {
        "editor.defaultFormatter"= "redhat.vscode-xml";
      };
      "[nix]"."editor.tabSize" = 2;
    };
  };
}
