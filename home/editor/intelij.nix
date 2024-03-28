{pkgs, ...}: {
  home.packages = with pkgs; [
    (jetbrains.plugins.addPlugins
      jetbrains.idea-ultimate ["github-copilot" "nixidea"])
  ];
}
