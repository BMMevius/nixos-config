{ ... }:

{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-WDS100T1X0E-00AFY0_211417442405";

    content = {
      type = "gpt";

      partitions = {
        ESP = {
          size = "1024M";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "fmask=0077" "dmask=0077" ];
          };
        };

        swap = {
          size = "34G";  # match your actual swap size
          content = {
            type = "luks";
            name = "cryptswap";  # your actual UUID
            content = {
              type = "swap";
            };
          };
        };

        luks = {
          size = "100%";

          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;
            content = {
              type = "filesystem";
              format = "btrfs";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
