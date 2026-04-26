{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  storageMountPoint = lib.attrByPath [ "bastiaan" "storage" "mountPoint" ] null osConfig;
  dolphinNasPath = lib.optionalString (storageMountPoint != null) "${storageMountPoint}/nas";
  dolphinPlacesFile = "${config.xdg.dataHome}/user-places.xbel";
in
{
  programs.plasma = {
    enable = true;

    # Breeze Dark global theme
    workspace = {
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      lookAndFeel = "org.kde.breezedark.desktop";
    };

    # NumLock on at startup
    input.keyboard.numlockOnStartup = "on";

    # Power management
    powerdevil = {
      AC = {
        autoSuspend.action = "nothing";
        whenLaptopLidClosed = "doNothing";
        dimDisplay.enable = false;
        turnOffDisplay.idleTimeout = "never";
      };
      battery = {
        autoSuspend = {
          action = "sleep";
          idleTimeout = 600; # 10 minutes
        };
        dimDisplay = {
          enable = true;
          idleTimeout = 300; # 5 minutes
        };
      };
      lowBattery = {
        autoSuspend = {
          action = "sleep";
          idleTimeout = 300; # 5 minutes
        };
      };
    };
  };

  home.activation.dolphinNasPlace = lib.mkIf (storageMountPoint != null) (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$(dirname "${dolphinPlacesFile}")"

    if [ ! -f "${dolphinPlacesFile}" ]; then
      cat > "${dolphinPlacesFile}" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xbel>
<xbel xmlns:bookmark="http://www.freedesktop.org/standards/desktop-bookmarks" xmlns:kdepriv="http://www.kde.org/kdepriv" xmlns:mime="http://www.freedesktop.org/standards/shared-mime-info">
</xbel>
EOF
    fi

    if ! grep -Fq 'file://${dolphinNasPath}' "${dolphinPlacesFile}"; then
      ${pkgs.perl}/bin/perl -0pi -e 's#</xbel># <bookmark href="file://${dolphinNasPath}">\n  <title>NAS</title>\n  <info>\n   <metadata owner="http://freedesktop.org">\n    <bookmark:icon name="inode-directory"/>\n   </metadata>\n   <metadata owner="http://www.kde.org">\n    <ID>nixos-dolphin-nas-place</ID>\n   </metadata>\n  </info>\n </bookmark>\n</xbel>#' "${dolphinPlacesFile}"
    fi
  '');
}
