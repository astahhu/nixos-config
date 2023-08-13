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
}
