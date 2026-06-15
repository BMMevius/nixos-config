{ pkgs, ... }:
{
  security.pam.services.login.enableKwallet = true;

  services.dbus.packages = [ pkgs.kdePackages.kwallet ];
  services.udisks2.enable = true;
  security.polkit.enable = true;

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
  ];
}
