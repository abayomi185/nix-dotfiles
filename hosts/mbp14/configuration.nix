{
  inputs,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    # Darwin Apps - See ../../modules/darwin/apps/default.nix
    # outputs.darwinModules.apps.karabiner-elements

    # Darwin Desktop - See ../../modules/darwin/desktop/default.nix
    outputs.darwinModules.desktop.skhd
    # outputs.darwinModules.desktop.spacebar
    outputs.darwinModules.desktop.yabai

    # Homebrew - See ./brew.nix
    ./homebrew.nix

    # Defaults - See ./system.nix
    ./system.nix
  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # nix.package = pkgs.nix;

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # Deduplicate and optimize nix store
  nix.optimise.automatic = true;

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
  };

  # nixpkgs = {
  #   # You can add overlays here
  #   overlays = [
  #     # Add overlays your own flake exports (from overlays and pkgs dir):
  #     outputs.overlays.additions
  #     outputs.overlays.modifications
  #     outputs.overlays.stable-packages
  #     outputs.overlays.unstable-packages
  #   ];
  # };

  # Define a user account
  system.primaryUser = "yomi"; # Required for darwin
  users.users = {
    yomi = {
      home = "/Users/yomi";
      shell = "${pkgs.zsh}/bin/zsh";

      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];

      packages = with pkgs; [
        # NOTE: Packages are installed via home-manager
        home-manager
        # firefox
        # thunderbird
      ];
    };
  };

  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.${system}.default
    # inputs.wezterm.packages.${system}.default
  ];

  # Creates global /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true; # Important!

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
