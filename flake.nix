{
  description = "NixOS configuration, Yay!";

  inputs = {
    ### -- nix
    parts.url = "github:hercules-ci/flake-parts";

    ### -- nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    ### language support
    # rust-overlay.url = "github:oxalica/rust-overlay";

    ### -- platform support
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # https://github.com/shaunsingh/nix-darwin-dotfiles

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];
    # perSystem = { config, self', inputs', pkgs, system, ... }: {
    #   # Per-system attributes can be defined here. The self' and inputs'
    #   # module parameters provide easy access to attributes of the same
    #   # system.
    #
    #   # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
    #   packages.default = pkgs.hello;
    # };
    imports = [ ./hosts ];
    # flake = {
    #   # The usual flake attributes can be defined here, including system-
    #   # agnostic ones like nixosModule and system-enumerating ones, although
    #   # those are more easily expressed in perSystem.
    #
    # };
  };

  # outputs = { self, nixpkgs, home-manager, ... }@inputs: {
  #   nixosConfigurations = {
  #     x280 = lib.nixosSystem {
  #       modules = [ ./hosts/x280/configuration.nix ];
  #       specialArgs = { inherit inputs outputs; };
  #     };
  #   };
  #   # homeConfigurations = {
  #   #   x280 = lib.homeManagerConfiguration {
  #   #     inherit pkgs
  #   #     modules = [ ./hosts/x280/home.nix ];
  #   #     extraSpecialArgs = { inherit inputs outputs; };
  #   #   };
  #   # };
  # };
}
