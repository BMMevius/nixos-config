{ ... }:

{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/ata-ST3000DM008-2DM166_Z5051QPN";

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
            name = "luks-ed6165ce-68f1-4c99-b2fd-1875a5f07219";  # your actual UUID
            content = {
              type = "swap";
            };
          };
        };

        luks = {
          size = "100%";

          content = {
            type = "luks";
            name = "luks-a02978f8-166b-4d7a-8052-a08b4b1ae82c";
            settings.allowDiscards = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
