{
  description = "NixOS-VPS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    nixosConfigurations."vps-arm64" = inputs.nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = {inherit inputs outputs;};
      modules = [
        # NOTE: configuration.nix
        (
          {pkgs, ...}: {
            imports = [
              ./hardware-configuration.nix
              ./networking.nix
            ];

            # Hetzner
            boot.tmp.cleanOnBoot = true;
            zramSwap.enable = true;
            networking.hostName = "vps-arm64";
            networking.domain = "";

            programs.nix-ld.enable = true; # Enable nix-ld - it just works

            nix.settings = {
              experimental-features = "nix-command flakes";
              auto-optimise-store = true;
            };

            # Shell
            programs.zsh = {enable = true;};
            # Define a user account
            users.users = {
              cloud = {
                isNormalUser = true;
                description = "cloud";
                shell = pkgs.zsh;
                extraGroups = ["wheel"];
              };
            };

            # Containers
            virtualisation.containers.enable = true;
            virtualisation = {
              podman = {
                enable = true;
                dockerCompat = true;
                defaultNetwork.settings.dns_enabled = true;
              };
            };

            # Programs
            programs.neovim = {
              enable = true;
              defaultEditor = true;
            };

            # Services
            services.openssh = {
              enable = true;
              # Let's not repeat last time's mistake
              # settings = {
              #   PermitRootLogin = "no";
              # };
            };
            users.users.root.openssh.authorizedKeys.keys = [
              ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMv1YzJ8VMLq/vIgupcFHVmFUzFFlSeaPRTWFeqok67g yomi@A-MacBook-Pro''
              ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILiszq0SnlTlq1MM9jR5/wQO0pyVhGU9OnLebTEtdzJ7 yomi@nixos''
            ];
            users.users.cloud.openssh.authorizedKeys.keys = [
              ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMv1YzJ8VMLq/vIgupcFHVmFUzFFlSeaPRTWFeqok67g yomi@A-MacBook-Pro''
              ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILiszq0SnlTlq1MM9jR5/wQO0pyVhGU9OnLebTEtdzJ7 yomi@nixos''
            ];

            # System Packages
            environment.systemPackages = with pkgs; [
              zig
              podman-tui
              podman-compose
            ];

            system.stateVersion = "23.11";
          }
        )
        # NOTE: Home manager - home.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs outputs;};
          home-manager.users.cloud = {pkgs, ...}: {
            home.username = "cloud";
            home.homeDirectory = "/home/cloud";
            home.packages = with pkgs; [
              alejandra
              nil
              nixpkgs-fmt
              btop
              lazygit
              lua-language-server
              nodejs_18
              stylua
              selene
            ];

            # NOTE: Shells
            programs.zsh = {
              enable = true;
              autosuggestion.enable = true;
              enableCompletion = true;
              syntaxHighlighting.enable = true;
              history.size = 10000;
              shellAliases = {
                la = "ls -la";
                check = "nix flake check";
                update = "sudo nixos-rebuild switch";
                garbage = "sudo nix-collect-garbage --delete-older-than";
                develop = "nix develop -c $SHELL";
              };
              # zshrc equivalent
              # initExtra = "";
              # zshenv equivalent
              # envExtra = "";
              # zprofile equivalent
              # profileExtra = "";

              oh-my-zsh = {
                enable = true;
                plugins = ["git" "vi-mode"];
                theme = "robbyrussell";
              };
            };
            programs.direnv = {
              enable = true;
              enableZshIntegration = true;
              nix-direnv.enable = true;
            };
            programs.bat = {
              enable = true;
            };
            programs.git = {
              enable = true;
              userName = "Yomi Ikuru";
              userEmail = "yomi+git@yomitosh.com";
            };

            programs.home-manager.enable = true;
            systemd.user.startServices = "sd-switch";
            home.stateVersion = "23.11";
          };
        }
      ];
    };
  };
}
