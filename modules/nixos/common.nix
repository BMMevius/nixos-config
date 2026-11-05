{ pkgs, ... }:
{
  services.envfs.enable = true;
  programs.direnv.enable = true;

  environment.systemPackages = [ pkgs.bash ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    http-connections = 50;
    max-substitution-jobs = 32;
  };
}
