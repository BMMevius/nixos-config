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
    ../../modules/home-manager/ktorrent.nix
    ../../modules/home-manager/office.nix
    ../../modules/home-manager/openboard.nix
    ../../modules/home-manager/plasma.nix
    ../../modules/home-manager/signal.nix
    ../../modules/home-manager/strawberry.nix
    ../../modules/home-manager/teams.nix
    ../../modules/home-manager/vscode.nix
    ../../modules/home-manager/vlc.nix
    # ../../modules/home-manager/winboat.nix
  ]
  ++ lib.optionals (osConfig.networking.hostName == "desktop") [
    ../../hosts/desktop/display-configuration.nix
  ];

  home.username = "bastiaan";
  home.homeDirectory = "/home/bastiaan";

  # Enable home-manager modules
  home.stateVersion = "25.11"; # match your NixOS version
}
