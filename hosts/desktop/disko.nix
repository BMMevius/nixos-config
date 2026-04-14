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

  # Disko does not set neededForBoot for btrfs subvolumes.
  # The "/" and "/nix" mountpoints are automatically detected as needed for boot
  # by NixOS (via utils.fsNeededForBoot), but we explicitly ensure all critical
  # subvolumes are marked, which adds "x-initrd.mount" to their fstab options
  # so systemd initrd mounts them at /sysroot/* before switch-root.
  fileSystems."/".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/home".neededForBoot = true;
  fileSystems."/swap".neededForBoot = true;
}
