{ pkgs, ... }:
{
  home.packages = [
    pkgs.strawberry
  ];

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
