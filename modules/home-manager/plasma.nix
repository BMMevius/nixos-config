{ ... }:
{
  programs.plasma = {
    enable = true;

    # Breeze Dark global theme
    workspace = {
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      lookAndFeel = "org.kde.breezedark.desktop";
    };

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
}
