{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    astahhu.desktop.firefox.enable = lib.mkEnableOption "Enable Firefox";
  };

  config = lib.mkIf config.astahhu.desktop.firefox.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-esr;
      policies = {
        DisableTelemetry = true;
        DisablePocket = true;
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        SearchEngines = {
          Add = [
            {
              Name = "Nix Packages";
              URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
              IconURL = "https://search.nixos.org/images/nix-logo.png";
              Alias = "@pkgs";
              Description = "NixOs Packages";
              Method = "GET";
            }
            {
              Name = "NixOs Options";
              URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
              IconURL = "https://search.nixos.org/images/nix-logo.png";
              Alias = "@nixos";
              Description = "NixOs Options";
              Method = "GET";
            }
          ];
          Remove = [
            "Google"
          ];
          PreventInstalls = true;
        };
      };
    };
  };
}
