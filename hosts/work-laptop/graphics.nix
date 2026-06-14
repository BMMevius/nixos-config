{ config, pkgs, ... }: {
  # Enable OpenGL
  hardware.graphics = {
    # or hardware.opengl in older versions
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Intel QuickSync
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required
    modesetting.enable = true;
    powerManagement.enable = true; # Helps with sleep/wake

    # Use prime offload for laptops
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Make sure to run `lspci` to get correct bus IDs
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    # Use proprietary drivers
    open = false; # T1200 is pre-post-Turing
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
