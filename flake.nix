{
  description = "NixOS configuration, Yay!";

  inputs = {
    # Nixpkgs
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Darwin
    nixpkgs-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Any other flake needed
    hardware.url = "github:nixos/nixos-hardware";

    # Fingerprint
    nixos-06cb-009a-fingerprint-sensor = {
      url = "github:ahbnr/nixos-06cb-009a-fingerprint-sensor";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Hyprland
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    # hyprland.url = "github:hyprwm/Hyprland"; # old
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # AGS
    ags.url = "github:Aylur/ags";

    # Dev
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Sops
    sops-nix.url = "github:Mic92/sops-nix";

    # KDE Plasma
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };

    # Nix Colors
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = {
    self,
    home-manager,
    nix-homebrew,
    nix-colors,
    rust-overlay,
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
    forAllSystems = inputs.nixpkgs-unstable.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (
      system: let
        pkgs = import inputs.nixpkgs-unstable {
          inherit system;
          overlays = [(import rust-overlay)];
        };
      in
        import ./pkgs {inherit pkgs;}
    );
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: inputs.nixpkgs-unstable.legacyPackages.${system}.alejandra);

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
      x1c6 = inputs.nixpkgs-unstable.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./hosts/x1c6/configuration.nix
          home-manager.nixosModules.home-manager
          {
            # home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs outputs nix-colors;};
            home-manager.users.yomi = import ./hosts/x1c6/home.nix;
            home-manager.sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
            ];
          }
        ];
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

      # MacBook Air 10,1
      MacBook-Air = inputs.nixpkgs-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs outputs;
        };
        modules = [
          # > Our main nixos configuration file <
          ./hosts/mba13/configuration.nix
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nixpkgs.hostPlatform = "aarch64-darwin";

            # home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs outputs nix-colors;};
            home-manager.users.yomi = import ./hosts/mba13/home.nix;
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
      "yomi@x1c6" = home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs nix-colors;};
        modules = [
          ./hosts/x1c6/home.nix
        ];
      };

      "yomi@A-MacBook-Pro-eth.lan" = home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs nix-colors;};
        modules = [
          ./hosts/mbp16/home.nix
        ];
      };

      "yomi@A-MacBook-Air.lan" = home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs nix-colors;};
        modules = [
          ./hosts/mba13/home.nix
        ];
      };
    };
  };
}
