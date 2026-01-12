{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    open-dyslexic
    nerd-fonts.fira-code
  ];
}
