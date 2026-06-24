{
  description = "System flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      disko,
      ...
    }:
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit nixpkgs-unstable;
        };
        modules = [
          ./hosts/desktop/configuration.nix
          ./modules/nixos/tailscale.nix
          ./modules/nixos/boot.nix
          ./modules/nixos/firefox.nix
          ./modules/graphics/gtx970.nix
          ./modules/nixos/kde.nix
          ./modules/nixos/l2tp-vpn.nix
          ./modules/nixos/docker.nix
          ./modules/nixos/docker-gpu.nix
          ./modules/nixos/steam.nix
          ./modules/nixos/jellyfin-arr.nix
          ./modules/nixos/common.nix
          ./hosts/desktop/disko.nix
          ./modules/nixos/nextcloud.nix
          ./modules/nixos/greetd.nix
          ./modules/nixos/uwsm.nix
          disko.nixosModules.disko
          # home-manager integration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.bastiaan = import ./home/user/home.nix;
            home-manager.extraSpecialArgs = {
              pkgs-unstable = import nixpkgs-unstable {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            };
          }
        ];
      };

      nixosConfigurations.work-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit nixpkgs-unstable;
        };
        modules = [
          ./hosts/work-laptop/configuration.nix
          ./hosts/work-laptop/hardware-configuration.nix
          ./hosts/work-laptop/graphics.nix
          ./modules/nixos/boot.nix
          ./modules/nixos/firefox.nix
          ./modules/nixos/kde.nix
          ./modules/nixos/l2tp-vpn.nix
          ./modules/nixos/docker.nix
          ./modules/nixos/docker-gpu.nix
          ./modules/nixos/steam.nix
          ./modules/nixos/common.nix
          ./modules/nixos/greetd.nix
          ./modules/nixos/uwsm.nix
          # ./modules/disko/luks.nix
          disko.nixosModules.disko
          # home-manager integration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.bastiaan = import ./home/user/home.nix;
            home-manager.extraSpecialArgs = {
              pkgs-unstable = import nixpkgs-unstable {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            };
          }
        ];
      };

      packages.x86_64-linux.default = self.nixosConfigurations.desktop.config.system.build.toplevel;
    };
}
