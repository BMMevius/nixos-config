{ pkgs, ... }:
{
  security.pam.services.login.enableKwallet = true;

  services.dbus.packages = [ pkgs.kdePackages.kwallet ];
  services.udisks2.enable = true;
  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.kwalletmanager
    kdePackages.kwallet-pam
    kdePackages.kwallet
    kdePackages.dolphin
  ];
}
