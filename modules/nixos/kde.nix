{ pkgs, ... }:
{
  security.pam.services.login.enableKwallet = true;

  services.dbus.packages = [ pkgs.kdePackages.kwallet ];
  services.udisks2.enable = true;
  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
    config.common.default = [
      "hyprland"
      "kde"
    ];
  };

  xdg.mime.defaultApplications = {
    "image/*" = [ "qimgv.desktop" ];
    "video/*" = [ "vlc.desktop" ];

    "text/*" = [ "code.desktop" ];
    "application/json" = [ "code.desktop" ]; # JSON is technically an application type

    "text/html" = [ "firefox.desktop" ];
    "text/csv" = [ "libreoffice-calc.desktop" ];

    "application/pdf" = [ "firefox.desktop" ];
    "application/xhtml+xml" = [ "firefox.desktop" ];

    "application/msword" = [ "libreoffice-writer.desktop" ];
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
      "libreoffice-writer.desktop"
    ];
    "application/vnd.oasis.opendocument.text" = [ "libreoffice-writer.desktop" ];

    "application/vnd.ms-excel" = [ "libreoffice-calc.desktop" ];
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [
      "libreoffice-calc.desktop"
    ];
    "application/vnd.oasis.opendocument.spreadsheet" = [ "libreoffice-calc.desktop" ];

    "application/vnd.ms-powerpoint" = [ "libreoffice-impress.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
      "libreoffice-impress.desktop"
    ];
    "application/vnd.oasis.opendocument.presentation" = [ "libreoffice-impress.desktop" ];
  };

  xdg.mime.enable = true;

  # Allow wheel group users to modify NetworkManager connections without password prompts.
  # Uses two complementary rules: one for permission grants, one to handle secrets fetching.
  environment.etc."polkit-1/rules.d/49-networkmanager-wheel.rules".text = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.NetworkManager.") == 0 && 
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  environment.etc."polkit-1/rules.d/50-networkmanager-secrets.rules".text = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.NetworkManager.settings.modify.hostname" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  environment.systemPackages = with pkgs; [
    kdePackages.kwalletmanager
    kdePackages.kwallet-pam
    kdePackages.kwallet
    kdePackages.dolphin
    kdePackages.kio-extras
    kdePackages.breeze-icons
    shared-mime-info
    xdg-utils
  ];
}
