{ pkgs, ... }:
{
  hardware.nvidia-container-toolkit.enable = true;

  # Use nvidia-container-toolkit's runtime with Docker
  virtualisation.docker.daemon.settings = {
    features.cdi = true;
  };
}
