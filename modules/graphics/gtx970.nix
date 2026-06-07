{
  config,
  pkgs,
  lib,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    branch = "legacy_580";
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;
  };
}
