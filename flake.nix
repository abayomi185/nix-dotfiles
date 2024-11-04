{
  description = "NixOS configuration, Yay!";

  inputs = {
    # Nixpkgs
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Darwin
    nixpkgs-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";

    # Any other flake needed
    hardware.url = "github:nixos/nixos-hardware";

    # AGS
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Dev
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Sops
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Agenix
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Nix Colors
    nix-colors.url = "github:misterio77/nix-colors";

    compose2nix = {
      url = "github:aksiksi/compose2nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Secrets
    nix-secrets = {
      url = "git+ssh://git@github.com/abayomi185/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };

    # Brew Nix
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };
    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.brew-api.follows = "brew-api";
    };
  };

  outputs = {
    self,
    agenix,
    home-manager,
    nix-colors,
    nix-homebrew,
    rust-overlay,
    sops-nix,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = inputs.nixpkgs-stable.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (
      system: let
        pkgs = import inputs.nixpkgs-stable {
          inherit system;
          overlays = [(import rust-overlay)];
        };
      in
        import ./pkgs {inherit pkgs;}
    );

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: inputs.nixpkgs-stable.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;
    # For darwin-specific modules
    darwinModules = import ./modules/darwin;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # x1c6 = inputs.nixpkgs-stable.lib.nixosSystem {
      #   specialArgs = {inherit inputs outputs;};
      #   modules = [
      #     # > Our main nixos configuration file <
      #     ./hosts/x1c6/configuration.nix
      #     home-manager.nixosModules.home-manager
      #     {
      #       # home-manager.useGlobalPkgs = true;
      #       home-manager.useUserPackages = true;
      #       home-manager.extraSpecialArgs = {inherit inputs outputs nix-colors;};
      #       home-manager.users.yomi = import ./hosts/x1c6/home.nix;
      #       home-manager.sharedModules = [
      #         inputs.sops-nix.homeManagerModules.sops
      #       ];
      #     }
      #   ];
      # };

      vps-arm64 = inputs.nixpkgs-stable.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./hosts/vps/configuration.nix
          sops-nix.nixosModules.sops
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            # home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs outputs;};
            home-manager.users.cloud = import ./hosts/vps/home.nix;
            home-manager.sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
            ];
          }
        ];
      };

      vm-game = inputs.nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./hosts/game/configuration.nix
          sops-nix.nixosModules.sops
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs outputs;};
            home-manager.users.cloud = import ./hosts/game/home.nix;
            home-manager.sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
            ];
          }
        ];
      };
    };

    # Kubernetes cluster definition
    nixosConfigurations = {
      knode1 = import ./hosts/knode/default.nix {
        inherit inputs outputs;
        pNodeId = 1;
        pK3sRole = "server";
        pK3sClusterInit = true;
        pK3sServerId = 1;
      };
      knode2 = import ./hosts/knode/default.nix {
        inherit inputs outputs;
        pNodeId = 2;
        pK3sRole = "server";
        pK3sServerId = 1;
      };
      knode3 = import ./hosts/knode/default.nix {
        inherit inputs outputs;
        pNodeId = 3;
        pK3sRole = "server";
        pK3sServerId = 1;
      };
    };

    darwinConfigurations = {
      # MacBook Pro 18,2
      MacBook-Pro = inputs.nixpkgs-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs outputs;
        };
        modules = [
          # > Our main nixos configuration file <
          ./hosts/mbp16/configuration.nix
          agenix.darwinModules.default
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nixpkgs.hostPlatform = "aarch64-darwin";

            # home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs outputs nix-colors;};
            home-manager.users.yomi = import ./hosts/mbp16/home.nix;
            home-manager.sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
            ];

            nix-homebrew.enable = true;
            nix-homebrew.enableRosetta = true;
            nix-homebrew.user = "yomi";
            nix-homebrew.autoMigrate = true;
          }
        ];
      };

      # MacBook Pro 18,3
      MacBook-Pro-14 = inputs.nixpkgs-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs outputs;
        };
        modules = [
          # > Our main nixos configuration file <
          ./hosts/mbp14/configuration.nix
          agenix.darwinModules.default
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nixpkgs.hostPlatform = "aarch64-darwin";

            # home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs outputs nix-colors;};
            home-manager.users.yomi = import ./hosts/mbp14/home.nix;
            home-manager.sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
            ];

            nix-homebrew.enable = true;
            nix-homebrew.enableRosetta = true;
            nix-homebrew.user = "yomi";
            nix-homebrew.autoMigrate = true;
          }
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "yomi@A-MacBook-Pro-eth.lan" = home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs-stable.legacyPackages.aarch64-darwin; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs nix-colors;};
        modules = [
          ./hosts/mbp16/home.nix
        ];
      };

      "yomi@MacBook-Pro-14.lan" = home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs-stable.legacyPackages.aarch64-darwin; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs nix-colors;};
        modules = [
          ./hosts/mbp14/home.nix
        ];
      };
    };
  };
}
