{ pkgs, ...} : {
  home.packages = with pkgs; [
    (jetbrains.plugins.addPlugins 
      jetbrains.idea-ultimate [ "github-copilot" "nixidea" ])
    (jetbrains.plugins.addPlugins 
      jetbrains.rust-rover [ "github-copilot" "nixidea"])
  ];


}
