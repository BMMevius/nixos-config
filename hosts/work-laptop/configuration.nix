# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
  boot.loader.efi = {
    efiSysMountPoint = "/boot";
  };
  boot.initrd.availableKernelModules = [
    "usb_storage"
    "usbhid"
    "btrfs"
  ];
  users.users.root.initialHashedPassword = "";

  networking.hostName = "laptop-bastiaan"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;

  # Docker's bridge networking needs br_netfilter (it has no broken install hook).
  boot.kernelModules = [ "br_netfilter" ];

  # This host runs NixOS on top of a foreign/FHS base system (note /usr/bin/modprobe
  # and /etc/static -> /.host-etc/static). A host-provided modprobe.d snippet ships a
  # broken `install nf_conntrack` hook that calls the non-existent /usr/bin/modprobe
  # and /sbin/sysctl, so systemd-modules-load and kernel auto-loading fail to load
  # nf_conntrack and its dependants (nf_nat, nft_ct, nft_chain_nat). That breaks
  # nftables `ct state` rules and Docker's NAT chains. Modprobe.d overrides are
  # unreliable here because the config path is contested by the host, so load the
  # modules explicitly with --ignore-install (which bypasses the broken hook) before
  # the firewall and Docker start.
  systemd.services.load-netfilter-modules = {
    description = "Load netfilter/conntrack kernel modules for nftables and Docker";
    before = [
      "nftables.service"
      "docker.service"
    ];
    wantedBy = [
      "nftables.service"
      "docker.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.kmod}/bin/modprobe --ignore-install -a nf_conntrack nf_nat nft_ct nft_chain_nat";
    };
  };

  # Load redistributable firmware (WiFi firmware blobs for Intel/Realtek/Broadcom etc.)
  hardware.enableRedistributableFirmware = true;

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
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  boot.supportedFilesystems = [
    "ntfs"
  ];
  environment.systemPackages = [
    pkgs.ntfs3g
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.11"; # Did you read the comment?

}
