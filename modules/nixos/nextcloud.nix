{
  config,
  pkgs,
  lib,
  ...
}:

let
  storageMountPoint = config.bastiaan.storage.mountPoint;
in

{
  services.nextcloud = {
    package = pkgs.nextcloud33;
    enable = true;
    hostName = "desktop.local";
    https = false;
    home = "/mnt/storage/nas/Nextcloud";
    datadir = "/mnt/storage/nas/Nextcloud";
    configureRedis = true;
    database.createLocally = false;
    appstoreEnable = false;
    extraAppsEnable = true;
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) memories;
    };
    settings = {
      updatechecker = false;
      "upgrade.disable-web" = true;
      trusted_domains = [
        "desktop"
        "desktop.local"
        "192.168.1.88"
      ];
      overwriteprotocol = "http";
      "overwrite.cli.url" = "http://desktop.local";
    };
    config = {
      dbtype = "pgsql";
      dbhost = "localhost";
      dbuser = "nextcloud";
      dbname = "nextcloud";
      dbpassFile = "/mnt/storage/nas/Nextcloud/dbpass";
      adminuser = "admin";
      adminpassFile = "/mnt/storage/nas/Nextcloud/adminpass";
    };
  };

  systemd.services.nextcloud-setup = {
    postStart = ''
      ${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:set \
        memories maps_tile_server \
        --value="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
    '';
  };

  # Ensure the writable store-apps directory exists on the ZFS dataset.
  # The Nextcloud module creates this via tmpfiles, but if the dataset is
  # new or was recreated, the directory won't exist and nextcloud-setup fails.
  systemd.tmpfiles.rules = [
    "d /mnt/storage/nas/Nextcloud/store-apps 0750 nextcloud nextcloud -"
  ];

  # Ensure cron cannot run before initial Nextcloud setup is complete.
  systemd.services.nextcloud-cron = {
    requires = [ "nextcloud-setup.service" ];
    after = [
      "nextcloud-setup.service"
      "zfs-import.target"
      "zfs-mount.service"
    ];
    unitConfig.RequiresMountsFor = [ storageMountPoint ];
  };

  # Ensure setup runs after tmpfiles has created the writable store-apps directory,
  # avoiding a race condition during nixos-rebuild switch activation.
  systemd.services.nextcloud-setup = {
    after = [
      "systemd-tmpfiles-setup.service"
      "systemd-tmpfiles-resetup.service"
      "zfs-import.target"
      "zfs-mount.service"
    ];
    unitConfig.RequiresMountsFor = [ storageMountPoint ];
  };

  systemd.services."phpfpm-nextcloud".unitConfig.RequiresMountsFor = [ storageMountPoint ];

  services.postgresql = {
    enable = true;
    dataDir = "/mnt/storage/nas/NextcloudDB";
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
    ];
  };

}
