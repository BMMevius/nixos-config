{ ... }:
{
  programs.git = {
    enable = true;
    settings.user.name = "Bastiaan Mevius";
    settings.user.email = "bastiaanmevius@gmail.com";
    # signing.key = "YOUR-GPG-KEY-ID"; # optional
  };
}
