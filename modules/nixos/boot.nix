{ pkgs, ... }:
{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Plymouth splash screen (shows during LUKS decryption)
  boot.plymouth = {
    enable = true;
    theme = "breeze";
  };

  # Silent boot for a clean graphical experience
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_level=3"
  ];
}
