{ pkgs, ... }:
{
  systemd.services.greetd.serviceConfig.KeyringMode = pkgs.lib.mkForce "inherit";

  security.pam.services.greetd.text = pkgs.lib.mkMerge [
    (pkgs.lib.mkBefore ''
      auth optional ${pkgs.systemd}/lib/security/pam_systemd_loadkey.so
      auth include login
      account include login
      password include login
      session include login
    '')
    (pkgs.lib.mkAfter ''
      session optional ${pkgs.pam_fde_boot_pw}/lib/security/pam_fde_boot_pw.so
      session optional ${pkgs.kdePackages.kwallet-pam}/lib/security/pam_kwallet5.so auto_start
    '')
  ];
  security.pam.services.greetd.enableKwallet = true;

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${pkgs.uwsm}/bin/uwsm start hyprland";
        user = "bastiaan";
      };
      default_session = {
        # This is the "fallback" if you log out
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd 'uwsm start hyprland'";
        user = "greeter";
      };
    };
  };
}
