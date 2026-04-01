{ lib, ... }:
{
  options.bastiaan.storage.mountPoint = lib.mkOption {
    type = lib.types.str;
    default = "/mnt/storage";
    example = "/mnt/storage";
    description = "Desktop-only shared storage mount point available to host and Home Manager modules.";
  };
}