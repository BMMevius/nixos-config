{ config, pkgs, lib, ... }:
let
  collectionPath = "/mnt/storage/Music";
  strawberryDbPath = "${config.xdg.dataHome}/strawberry/strawberry/strawberry.db";
  strawberryConfPath = "${config.xdg.configHome}/strawberry/strawberry.conf";
in
{
  home.packages = [
    pkgs.strawberry
  ];

  home.activation.strawberryCollection = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$(dirname "${strawberryDbPath}")"
    ${pkgs.sqlite}/bin/sqlite3 "${strawberryDbPath}" 'CREATE TABLE IF NOT EXISTS directories (path TEXT NOT NULL, subdirs INTEGER NOT NULL);'
    ${pkgs.sqlite}/bin/sqlite3 "${strawberryDbPath}" "DELETE FROM directories WHERE path = '${collectionPath}'; INSERT INTO directories (path, subdirs) VALUES ('${collectionPath}', 1);"
  '';

  home.activation.strawberrySettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$(dirname "${strawberryConfPath}")"
    touch "${strawberryConfPath}"

    ${pkgs.crudini}/bin/crudini --set "${strawberryConfPath}" Collection startup_scan false
    ${pkgs.crudini}/bin/crudini --set "${strawberryConfPath}" Collection skip_articles_for_albums true
    ${pkgs.crudini}/bin/crudini --set "${strawberryConfPath}" Collection group_by1 3
    ${pkgs.crudini}/bin/crudini --set "${strawberryConfPath}" Collection group_by2 0
    ${pkgs.crudini}/bin/crudini --set "${strawberryConfPath}" Collection group_by3 0
    ${pkgs.crudini}/bin/crudini --set "${strawberryConfPath}" Collection group_by_version 1
    ${pkgs.crudini}/bin/crudini --set "${strawberryConfPath}" Covers types 'art_embedded, art_unset, art_manual, art_automatic'
    ${pkgs.crudini}/bin/crudini --set "${strawberryConfPath}" Covers save_type 3
  '';

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "audio/mpeg" = "org.strawberrymusicplayer.strawberry.desktop";
      "audio/flac" = "org.strawberrymusicplayer.strawberry.desktop";
      "audio/ogg" = "org.strawberrymusicplayer.strawberry.desktop";
      "audio/wav" = "org.strawberrymusicplayer.strawberry.desktop";
      "audio/x-wav" = "org.strawberrymusicplayer.strawberry.desktop";
      "audio/mp4" = "org.strawberrymusicplayer.strawberry.desktop";
      "audio/aac" = "org.strawberrymusicplayer.strawberry.desktop";
      "audio/x-vorbis+ogg" = "org.strawberrymusicplayer.strawberry.desktop";
      "audio/x-opus+ogg" = "org.strawberrymusicplayer.strawberry.desktop";
      "audio/x-ms-wma" = "org.strawberrymusicplayer.strawberry.desktop";
      "audio/x-aiff" = "org.strawberrymusicplayer.strawberry.desktop";
    };
  };
}
