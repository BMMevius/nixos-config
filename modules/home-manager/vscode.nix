{ config, pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    mutableExtensionsDir = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      github.copilot
      github.copilot-chat
    ];
  };

  home.packages = with pkgs; [
    nixfmt
  ];
}
