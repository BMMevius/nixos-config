# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  storageMountPoint = config.bastiaan.storage.mountPoint;
in

{
  imports = [
    # Include the results of the hardware scan.
    ./storage.nix
  ];


  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bastiaan = {
    isNormalUser = true;
    description = "bastiaan";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    packages = with pkgs; [ ];
  };

  # Enable fish system-wide (adds it to /etc/shells)
  programs.fish.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Windows Dynamic Disk (spanned volume across 2x 2.7T Seagate ST3000DM008)
  environment.systemPackages = [
    pkgs.ldmtool
    pkgs.ntfs3g
  ];

  # Activate LDM volumes and mount at boot (non-blocking)
  systemd.services.ldm-storage = {
    description = "Activate and mount Windows Dynamic Disk spanned volume";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-settle.service" ];
    wants = [ "systemd-udev-settle.service" ];
    path = [
      pkgs.ldmtool
      pkgs.ntfs3g
      pkgs.util-linux
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "ldm-mount" ''
        set -e
        ldmtool create all
        sleep 2

        LDM_DEV="/dev/mapper/ldm_vol_PC-BASTIAAN-Dg0_Volume1"
        if [ ! -e "$LDM_DEV" ]; then
          echo "LDM volume not found at $LDM_DEV, skipping mount"
          exit 0
        fi

        mkdir -p ${storageMountPoint}
        if ! mountpoint -q ${storageMountPoint}; then
          mount -t ntfs -o uid=1000,gid=100,dmask=022,fmask=133 "$LDM_DEV" ${storageMountPoint}
          echo "Mounted $LDM_DEV at ${storageMountPoint}"
        fi
      '';
      ExecStop = pkgs.writeShellScript "ldm-umount" ''
        umount ${storageMountPoint} 2>/dev/null || true
      '';
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
