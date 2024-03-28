{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions;
      [
        rust-lang.rust-analyzer
        jnoortheen.nix-ide
        redhat.vscode-xml
        github.copilot
        ms-azuretools.vscode-docker
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "a-file-icon-vscode";
          publisher = "AtomMaterial";
          version = "1.2.0";
          sha256 = "sha256-PgvhqqMvIvBej96mnoNMgtniuKHzlu+XB1rbSLqPF7E=";
        }
      ];
    userSettings = {
      editor.fontLigatures = true;
      git.confirmSync = false;
      git.autofetch = true;
      terminal.integrated.fontLigatures = true;
      "[xml]" = {
        editor.defaultFormatter = "redhat.vscode-xml";
      };
      "[nix]".editor.tabSize = 2;
      telemetry.telemetryLevel = "off";
      extensions.autoCheckUpdates = false;
      extensions.autoUpdate = false;
      workbench.iconTheme = "a-file-icon-vscode";
      window.zoomLevel = 1;
      explorer.confirmDragAndDrop = false;
    };
  };
}
