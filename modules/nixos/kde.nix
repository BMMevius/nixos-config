{ pkgs, ... }:
{
  services.desktopManager.plasma6.enable = true;
  services.displayManager = {
    sddm.enable = true;
    autoLogin = {
      enable = false;
      user = "bastiaan";
    };
    defaultSession = "plasma";
  };

  environment.plasma6.excludePackages = [
    pkgs.kdePackages.elisa
  ];
}
