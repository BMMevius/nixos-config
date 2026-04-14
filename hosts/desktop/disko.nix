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

        luks = {
          size = "100%";

          content = {
            type = "luks";
            name = "cryptroot";
            passwordFile = "/tmp/secret.key";
            settings = {
              allowDiscards = true;
            };
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/swap" = {
                  mountpoint = "/swap";
                  swap.swapfile.size = "34G";
                };
              };
            };
          };
        };
      };
    };
  };
}
