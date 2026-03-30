{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  # Needed for some Steam games
  programs.gamemode.enable = true;
}
