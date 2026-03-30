{ pkgs, ... }:
{
  home.packages = [
    pkgs.winboat
    pkgs.freerdp
  ];
}
