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
      inherit (config.services.nextcloud.package.packages.apps) memories richdocuments;
    };
    settings = {
      allow_local_remote_servers = true;
      updatechecker = false;
      "upgrade.disable-web" = true;
      trusted_domains = [
        "desktop"
        "desktop.local"
        "192.168.1.88"
        "localhost"
        "::1"
        "127.0.0.1"
      ];
      overwriteprotocol = "http";
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

  services.collabora-online = {
    enable = true;
    aliasGroups = [
      {
        host = "http://desktop.local";
        aliases = [
          "http://desktop"
          "http://192.168.1.88"
          "http://localhost"
          "http://127.0.0.1"
        ];
      }
    ];
    settings = {
      server_name = "desktop.local";
      ssl = {
        enable = false;
        termination = false;
      };

      # Restrict WOPI requests to Nextcloud instance only.
      # These are the addresses from which Nextcloud will request documents.
      storage.wopi = {
        "@allow" = true;
        host = [
          "127.0.0.1"
          "localhost"
          "192.168.1.88"
          "desktop"
          "desktop.local"
        ];
      };
    };
  };

  systemd.services.nextcloud-setup = {
    postStart = ''
      ${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:set \
        memories maps_tile_server \
        --value="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      ${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:set \
        richdocuments wopi_url \
        --value="http://desktop.local"
      ${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:set \
        richdocuments public_wopi_url \
        --value="http://desktop.local"
      ${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:set \
        richdocuments wopi_allowlist \
        --value="127.0.0.1,::1,192.168.1.88"
      ${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:delete \
        richdocuments wopi_callback_url || true
      ${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:delete \
        richdocuments disable_certificate_verification || true
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

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    serverAliases = [
      "desktop"
      "localhost"
      "127.0.0.1"
      "192.168.1.88"
    ];
    locations = {
      "^~ /browser" = {
        proxyPass = "http://127.0.0.1:9980";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
      "= /hosting/discovery" = {
        proxyPass = "http://127.0.0.1:9980/hosting/discovery";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
      "= /hosting/capabilities" = {
        proxyPass = "http://127.0.0.1:9980/hosting/capabilities";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
      "^~ /cool" = {
        proxyPass = "http://127.0.0.1:9980";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
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
