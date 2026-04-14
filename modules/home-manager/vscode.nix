{ config, pkgs, pkgs-unstable, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs-unstable.vscode.fhs;
    mutableExtensionsDir = true;
    profiles.default.extensions = with pkgs-unstable.vscode-extensions; [
      jnoortheen.nix-ide
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      github.copilot
      github.copilot-chat
      mkhl.shfmt
    ];
  };

  home.packages = with pkgs; [
    nixfmt
    shfmt
  ];
}
