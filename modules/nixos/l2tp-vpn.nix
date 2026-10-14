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

  # Add support for ikev1 in strongswan
  nixpkgs.overlays = [
    (self: super: {
      strongswan = super.strongswan.overrideAttrs (oldAttrs: {
        configureFlags = (oldAttrs.configureFlags or [ ]) ++ [
          "--enable-ikev1"
        ];
      });
    })
  ];
}
