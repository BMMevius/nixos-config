{ pkgs, ... }:
{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use systemd in initrd (required for LUKS + disko + Plymouth)
  boot.initrd.systemd.enable = true;

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
    "udev.log_level=3"
  ];
}
