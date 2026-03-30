{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/fish.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/plasma.nix
    ../../modules/home-manager/signal.nix
    ../../modules/home-manager/vscode.nix
  ];

  home.username = "bastiaan";
  home.homeDirectory = "/home/bastiaan";

  # Enable home-manager modules
  home.stateVersion = "25.11"; # match your NixOS version
}
