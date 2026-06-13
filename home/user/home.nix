{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

{
  imports = [
    ../../modules/home-manager/fish.nix
    ../../modules/home-manager/filelight.nix
    ../../modules/home-manager/fonts.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/office.nix
    ../../modules/home-manager/openboard.nix
    ../../modules/home-manager/signal.nix
    ../../modules/home-manager/teams.nix
    ../../modules/home-manager/vscode.nix
    ../../modules/home-manager/vlc.nix
    ../../modules/home-manager/hyprland.nix
    ../../modules/home-manager/image-viewer.nix
  ]
  ++ lib.optionals (osConfig.networking.hostName == "desktop") [
    ../../modules/home-manager/discord.nix
    ../../modules/home-manager/strawberry.nix
  ];

  home.username = "bastiaan";
  home.homeDirectory = "/home/bastiaan";
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Enable home-manager modules
  home.stateVersion = "26.05"; # match your NixOS version
}
