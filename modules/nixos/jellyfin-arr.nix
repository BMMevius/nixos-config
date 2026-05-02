{
  config,
  pkgs,
  ...
}:

let
  mediaRoot = "/mnt/storage/nas/Media";
  downloadsRoot = "${mediaRoot}/Downloads";
  filmRoot = "${mediaRoot}/Film";
  seriesRoot = "${mediaRoot}/Series";
in
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };
  services.radarr = {
    enable = true;
    openFirewall = true;
  };
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  services.transmission = {
    enable = true;
    openFirewall = true;
    settings = {
      "download-dir" = "${downloadsRoot}/completed";
      "incomplete-dir" = "${downloadsRoot}/incomplete";
      "incomplete-dir-enabled" = true;
      "umask" = 2;
      "rpc-bind-address" = "0.0.0.0";
      "rpc-whitelist-enabled" = false;
    };
  };

  users.users.radarr.extraGroups = [ "transmission" ];
  users.users.sonarr.extraGroups = [ "transmission" ];

  # Auto-wire Transmission + root folders into Radarr/Sonarr,
  # connect both to Prowlarr, and create Ultra-HD quality profiles.
  systemd.services.arr-bootstrap = {
    description = "Bootstrap ARR stack connections and 4K quality profiles";
    after = [
      "radarr.service"
      "sonarr.service"
      "prowlarr.service"
      "transmission.service"
    ];
    wants = [
      "radarr.service"
      "sonarr.service"
      "prowlarr.service"
      "transmission.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      curl
      jq
      gnugrep
      coreutils
      bash
    ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euo pipefail

      wait_for() {
        local url=$1 name=$2 n=0
        echo "Waiting for $name..."
        while ! curl -s -o /dev/null --max-time 5 "$url" 2>/dev/null; do
          n=$((n+1)); [ $n -ge 36 ] && { echo "$name not ready, skipping"; exit 0; }
          sleep 5
        done
        echo "$name ready"
      }

      get_key() { grep -oP '(?<=<ApiKey>)[^<]+' "$1" 2>/dev/null || true; }

      wait_for "http://localhost:7878/api/v3/system/status" "Radarr"
      wait_for "http://localhost:8989/api/v3/system/status" "Sonarr"
      wait_for "http://localhost:9696/api/v1/system/status" "Prowlarr"

      radarr_key=$(get_key /var/lib/radarr/.config/Radarr/config.xml)
      sonarr_key=$(get_key /var/lib/sonarr/.config/NzbDrone/config.xml)
      prowlarr_key=$(get_key /var/lib/prowlarr/config.xml)

      [ -z "$radarr_key" ]   && { echo "Radarr key missing";   exit 0; }
      [ -z "$sonarr_key" ]   && { echo "Sonarr key missing";   exit 0; }
      [ -z "$prowlarr_key" ] && { echo "Prowlarr key missing"; exit 0; }

      prowlarr_indexer_count=$(curl -s -H "X-Api-Key: $prowlarr_key" \
        http://localhost:9696/api/v1/indexer | jq 'length')
      if [ "$prowlarr_indexer_count" -eq 0 ]; then
        echo "Prowlarr has 0 indexers configured; add at least one indexer in Prowlarr first"
        exit 0
      fi

      # Ensure media directories exist (ZFS may not have been mounted when tmpfiles ran)
      mkdir -p "${filmRoot}" "${seriesRoot}" "${downloadsRoot}/completed" "${downloadsRoot}/incomplete"
      mkdir -p "${downloadsRoot}/completed/radarr" "${downloadsRoot}/completed/sonarr"
      # Some storage backends map ownership to nobody:nogroup; keep paths writable.
      chmod 0777 "${filmRoot}" "${seriesRoot}" \
        "${downloadsRoot}" "${downloadsRoot}/completed" "${downloadsRoot}/incomplete" \
        "${downloadsRoot}/completed/radarr" "${downloadsRoot}/completed/sonarr"

      #
      # ── Radarr ──────────────────────────────────────────────────────
      #

      # Transmission download client
      if ! curl -sf -H "X-Api-Key: $radarr_key" http://localhost:7878/api/v3/downloadclient \
          | jq -e '[.[].name] | contains(["Transmission"])' > /dev/null; then
        echo "Radarr: adding Transmission"
        jq -n '{
          name:"Transmission",enable:true,protocol:"torrent",priority:1,
          removeCompletedDownloads:true,removeFailedDownloads:true,
          fields:[
            {name:"host",value:"localhost"},{name:"port",value:9091},
            {name:"useSsl",value:false},{name:"urlBase",value:"/transmission/"},
            {name:"movieCategory",value:"radarr"},{name:"movieImportedCategory",value:""},
            {name:"recentMoviePriority",value:0},{name:"olderMoviePriority",value:0},
            {name:"addPaused",value:false}
          ],
          implementationName:"Transmission",implementation:"Transmission",
          configContract:"TransmissionSettings",tags:[]
        }' | curl -s -X POST -H "X-Api-Key: $radarr_key" \
            -H "Content-Type: application/json" -d @- \
            http://localhost:7878/api/v3/downloadclient
      fi

      # Root folder
      if ! curl -sf -H "X-Api-Key: $radarr_key" http://localhost:7878/api/v3/rootfolder \
          | jq -e --arg p "${filmRoot}" 'map(.path | rtrimstr("/")) | index($p) != null' > /dev/null; then
        echo "Radarr: adding root folder ${filmRoot}"
        jq -n --arg p "${filmRoot}/" '{path:$p}' \
          | curl -s -X POST -H "X-Api-Key: $radarr_key" \
              -H "Content-Type: application/json" -d @- \
              http://localhost:7878/api/v3/rootfolder

        if ! curl -sf -H "X-Api-Key: $radarr_key" http://localhost:7878/api/v3/rootfolder \
            | jq -e --arg p "${filmRoot}" 'map(.path | rtrimstr("/")) | index($p) != null' > /dev/null; then
          echo "Radarr: root folder still missing after add attempt"
        fi
      fi

      # Ultra-HD quality profile
      if ! curl -sf -H "X-Api-Key: $radarr_key" http://localhost:7878/api/v3/qualityprofile \
          | jq -e '[.[].name] | contains(["Ultra-HD"])' > /dev/null; then
        echo "Radarr: creating Ultra-HD profile"
        defs=$(curl -sf -H "X-Api-Key: $radarr_key" http://localhost:7878/api/v3/qualitydefinition)
        items=$(echo "$defs" | jq '[.[] | {quality:.quality,allowed:(.quality.name | test("2160|4K|UHD|Remux";"i")),items:[]}]')
        cutoff=$(echo "$defs" | jq 'map(select(.quality.name | test("2160|Remux";"i"))) | .[0].quality.id // 20')
        jq -n --argjson items "$items" --argjson cutoff "$cutoff" '{
          name:"Ultra-HD",upgradeAllowed:true,cutoff:$cutoff,
          items:$items,minFormatScore:0,cutoffFormatScore:0,
          formatItems:[],language:{id:1,name:"English"}
        }' | curl -s -X POST -H "X-Api-Key: $radarr_key" \
            -H "Content-Type: application/json" -d @- \
            http://localhost:7878/api/v3/qualityprofile
      fi

      #
      # ── Sonarr ──────────────────────────────────────────────────────
      #

      if ! curl -sf -H "X-Api-Key: $sonarr_key" http://localhost:8989/api/v3/downloadclient \
          | jq -e '[.[].name] | contains(["Transmission"])' > /dev/null; then
        echo "Sonarr: adding Transmission"
        jq -n '{
          name:"Transmission",enable:true,protocol:"torrent",priority:1,
          removeCompletedDownloads:true,removeFailedDownloads:true,
          fields:[
            {name:"host",value:"localhost"},{name:"port",value:9091},
            {name:"useSsl",value:false},{name:"urlBase",value:"/transmission/"},
            {name:"tvCategory",value:"sonarr"},{name:"tvImportedCategory",value:""},
            {name:"recentTvPriority",value:0},{name:"olderTvPriority",value:0},
            {name:"addPaused",value:false}
          ],
          implementationName:"Transmission",implementation:"Transmission",
          configContract:"TransmissionSettings",tags:[]
        }' | curl -s -X POST -H "X-Api-Key: $sonarr_key" \
            -H "Content-Type: application/json" -d @- \
            http://localhost:8989/api/v3/downloadclient
      fi

      if ! curl -sf -H "X-Api-Key: $sonarr_key" http://localhost:8989/api/v3/rootfolder \
          | jq -e --arg p "${seriesRoot}" 'map(.path | rtrimstr("/")) | index($p) != null' > /dev/null; then
        echo "Sonarr: adding root folder ${seriesRoot}"
        jq -n --arg p "${seriesRoot}/" '{path:$p}' \
          | curl -s -X POST -H "X-Api-Key: $sonarr_key" \
              -H "Content-Type: application/json" -d @- \
              http://localhost:8989/api/v3/rootfolder

        if ! curl -sf -H "X-Api-Key: $sonarr_key" http://localhost:8989/api/v3/rootfolder \
            | jq -e --arg p "${seriesRoot}" 'map(.path | rtrimstr("/")) | index($p) != null' > /dev/null; then
          echo "Sonarr: root folder still missing after add attempt"
        fi
      fi

      if ! curl -sf -H "X-Api-Key: $sonarr_key" http://localhost:8989/api/v3/qualityprofile \
          | jq -e '[.[].name] | contains(["Ultra-HD"])' > /dev/null; then
        echo "Sonarr: creating Ultra-HD profile"
        defs=$(curl -sf -H "X-Api-Key: $sonarr_key" http://localhost:8989/api/v3/qualitydefinition)
        items=$(echo "$defs" | jq '[.[] | {quality:.quality,allowed:(.quality.name | test("2160|4K|UHD|Remux";"i")),items:[]}]')
        cutoff=$(echo "$defs" | jq 'map(select(.quality.name | test("2160|Remux";"i"))) | .[0].quality.id // 20')
        jq -n --argjson items "$items" --argjson cutoff "$cutoff" '{
          name:"Ultra-HD",upgradeAllowed:true,cutoff:$cutoff,
          items:$items,minFormatScore:0,cutoffFormatScore:0,
          formatItems:[],language:{id:1,name:"English"}
        }' | curl -s -X POST -H "X-Api-Key: $sonarr_key" \
            -H "Content-Type: application/json" -d @- \
            http://localhost:8989/api/v3/qualityprofile
      fi

      #
      # ── Prowlarr ────────────────────────────────────────────────────
      #

      apps=$(curl -sf -H "X-Api-Key: $prowlarr_key" http://localhost:9696/api/v1/applications)

      if ! echo "$apps" | jq -e '[.[].name] | contains(["Radarr"])' > /dev/null; then
        echo "Prowlarr: adding Radarr"
        jq -n --arg key "$radarr_key" '{
          name:"Radarr",syncLevel:"fullSync",
          fields:[
            {name:"prowlarrUrl",value:"http://localhost:9696"},
            {name:"baseUrl",value:"http://localhost:7878"},
            {name:"apiKey",value:$key},
            {name:"syncCategories",value:[2000,2010,2020,2030,2040,2045,2050,2060]}
          ],
          implementationName:"Radarr",implementation:"Radarr",
          configContract:"RadarrSettings",tags:[]
        }' | curl -s -X POST -H "X-Api-Key: $prowlarr_key" \
            -H "Content-Type: application/json" -d @- \
            http://localhost:9696/api/v1/applications
      fi

      apps=$(curl -sf -H "X-Api-Key: $prowlarr_key" http://localhost:9696/api/v1/applications)
      if ! echo "$apps" | jq -e '[.[].name] | contains(["Sonarr"])' > /dev/null; then
        echo "Prowlarr: adding Sonarr"
        jq -n --arg key "$sonarr_key" '{
          name:"Sonarr",syncLevel:"fullSync",
          fields:[
            {name:"prowlarrUrl",value:"http://localhost:9696"},
            {name:"baseUrl",value:"http://localhost:8989"},
            {name:"apiKey",value:$key},
            {name:"syncCategories",value:[5000,5010,5020,5030,5040,5045,5050]}
          ],
          implementationName:"Sonarr",implementation:"Sonarr",
          configContract:"SonarrSettings",tags:[]
        }' | curl -s -X POST -H "X-Api-Key: $prowlarr_key" \
            -H "Content-Type: application/json" -d @- \
            http://localhost:9696/api/v1/applications
      fi

      echo "ARR bootstrap complete"
    '';
  };

  # Jellyfin library bootstrap (film + series)
  systemd.services.jellyfin-library-bootstrap = {
    description = "Bootstrap Jellyfin film and series libraries";
    after = [ "jellyfin.service" ];
    wants = [ "jellyfin.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euo pipefail
      base_url="http://127.0.0.1:8096"
      if ! ${pkgs.curl}/bin/curl --silent --fail "''${base_url}/Startup/Complete" > /dev/null; then
        echo "Jellyfin API not reachable; skipping"; exit 0
      fi
      [ ! -f /var/lib/jellyfin/bootstrap-api-key ] && { echo "No API key file; skipping"; exit 0; }
      api_key="$(${pkgs.coreutils}/bin/cat /var/lib/jellyfin/bootstrap-api-key)"
      auth="X-Emby-Token: ''${api_key}"
      libs="$(${pkgs.curl}/bin/curl --silent --fail -H "$auth" "''${base_url}/Library/VirtualFolders")"
      if ! echo "$libs" | ${pkgs.gnugrep}/bin/grep -q '"Path":"${filmRoot}"'; then
        ${pkgs.curl}/bin/curl --silent --fail -X POST -H "$auth" \
          --data-urlencode "name=Films" --data-urlencode "collectionType=movies" \
          --data-urlencode "paths=${filmRoot}" "''${base_url}/Library/VirtualFolders"
      fi
      if ! echo "$libs" | ${pkgs.gnugrep}/bin/grep -q '"Path":"${seriesRoot}"'; then
        ${pkgs.curl}/bin/curl --silent --fail -X POST -H "$auth" \
          --data-urlencode "name=Series" --data-urlencode "collectionType=tvshows" \
          --data-urlencode "paths=${seriesRoot}" "''${base_url}/Library/VirtualFolders"
      fi
    '';
  };

  systemd.tmpfiles.rules = [
    "d ${mediaRoot}              0755 root root -"
    "d ${filmRoot}               0777 root root -"
    "d ${seriesRoot}             0777 root root -"
    "d ${downloadsRoot}          0777 root root -"
    "d ${downloadsRoot}/completed 0777 root root -"
    "d ${downloadsRoot}/completed/radarr 0777 root root -"
    "d ${downloadsRoot}/completed/sonarr 0777 root root -"
    "d ${downloadsRoot}/incomplete 0777 root root -"
  ];
}
