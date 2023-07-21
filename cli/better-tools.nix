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
    cat = "bat";
  };
}
