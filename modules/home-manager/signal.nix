{ pkgs, ... }:
{
  home.packages = [
    pkgs.signal-desktop
  ];

  xdg.desktopEntries.signal = {
    name = "Signal";
    comment = "Private messaging from your desktop";
    exec = "signal-desktop --password-store=kwallet6 %U";
    icon = "signal-desktop";
    terminal = false;
    type = "Application";
    categories = [
      "Network"
      "InstantMessaging"
      "Chat"
    ];
    mimeType = [
      "x-scheme-handler/sgnl"
      "x-scheme-handler/signalcaptcha"
    ];
    settings = {
      StartupWMClass = "signal";
      Version = "1.5";
    };
  };
}
