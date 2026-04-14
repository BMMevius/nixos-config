{ pkgs, lib, ... }:
{
  # L2TP/IPsec VPN support for NetworkManager (KDE)
  services.xl2tpd.enable = true;
  services.strongswan.enable = true;

  networking.networkmanager.plugins = with pkgs; [
    networkmanager-l2tp
  ];

  environment.systemPackages = with pkgs; [
    kdePackages.plasma-nm
  ];

  # nm-l2tp-service spawns `ipsec start` outside the strongswan systemd service,
  # so the STRONGSWAN_CONF env var isn't set. Charon then falls back to
  # /etc/strongswan.conf which doesn't exist on NixOS, causing it to abort.
  # Provide a minimal /etc/strongswan.conf so charon can start.
  environment.etc."strongswan.conf".text = ''
    charon {
      plugins {
        stroke {
          secrets_file = /etc/ipsec.secrets
        }
      }
    }
  '';

  # KDE plasma-nm looks for the `ipsec` binary only in /usr/sbin and /sbin.
  # On NixOS the binary lives in the Nix store, so we symlink it to /usr/sbin
  # so that plasma-nm's L2tpIpsecWidget::hasIpsecDaemon() can find it.
  system.activationScripts.ipsec-symlink = lib.stringAfter [ "usrbinenv" ] ''
    mkdir -p /usr/sbin
    ln -sf ${pkgs.strongswan}/sbin/ipsec /usr/sbin/ipsec
  '';
}
