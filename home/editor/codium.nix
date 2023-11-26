{ pkgs, ...} : {
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
      jnoortheen.nix-ide
      AtomMaterial.a-file-icon-vscode
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
      "telemetry.telemetryLevel" = "off";
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
    };
  };
}
