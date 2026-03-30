{
  description = "System flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko,
      plasma-manager,
      ...
    }:
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/desktop/configuration.nix
          ./modules/nixos/boot.nix
          ./modules/graphics/gtx970.nix
          ./modules/nixos/kde.nix
          ./modules/nixos/docker.nix
          ./modules/nixos/docker-gpu.nix
          ./modules/nixos/steam.nix
          # ./modules/disko/luks.nix
          disko.nixosModules.disko
          {
            nix.settings = {
              experimental-features = [
                "nix-command"
                "flakes"
              ];
              http-connections = 50;
              max-substitution-jobs = 32;
            };
          }
          # home-manager integration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.bastiaan = import ./home/bastiaan/home.nix;
            home-manager.sharedModules = [
              plasma-manager.homeModules.plasma-manager
            ];
          }
        ];
      };

      packages.x86_64-linux.default = self.nixosConfigurations.desktop.config.system.build.toplevel;
    };
}
