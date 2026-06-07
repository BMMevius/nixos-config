{ pkgs, ... }:
{
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  security.pam.services.sddm.kwallet.enable = true;
  security.pam.services.login.enableKwallet = true;
  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland compositor managed by UWSM";
        binPath = "${pkgs.hyprland}/bin/hyprland";
      };
    };
  };

  services.dbus.packages = [ pkgs.kdePackages.kwallet ];

  environment.systemPackages = with pkgs; [
    kdePackages.kwalletmanager
    kdePackages.kwallet-pam
    kdePackages.kwallet
    kdePackages.dolphin
  ];
}
