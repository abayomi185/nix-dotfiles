# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # Or modules exported from other flakes (such as nix-colors):
    inputs.nix-colors.homeManagerModules.default

    # apps, editors, or devtools

    # All Modules - See ../../modules/home-manager/default.nix

    # Apps - See ../../modules/home-manager/apps/default.nix
    outputs.homeManagerModules.apps.bat
    outputs.homeManagerModules.apps.davinci-resolve-studio
    outputs.homeManagerModules.apps.discord
    outputs.homeManagerModules.apps.calibre
    outputs.homeManagerModules.apps.cura
    outputs.homeManagerModules.apps.k9s
    outputs.homeManagerModules.apps.neovim
    outputs.homeManagerModules.apps.obs
    outputs.homeManagerModules.apps.obsidian
    outputs.homeManagerModules.apps.orca-slicer
    outputs.homeManagerModules.apps.prusa-slicer
    outputs.homeManagerModules.apps.vscode

    # Browsers - See ../../modules/home-manager/browsers/default.nix
    outputs.homeManagerModules.browsers.brave
    outputs.homeManagerModules.browsers.firefox

    # Desktop - See ../../modules/home-manager/desktop/default.nix
    outputs.homeManagerModules.desktop.ags
    outputs.homeManagerModules.desktop.hyprland

    # Dev - See ../../modules/home-manager/dev/default.nix
    outputs.homeManagerModules.dev.rust
    outputs.homeManagerModules.dev.zig
    outputs.homeManagerModules.dev.nodejs

    # Music - See ../../modules/home-manager/music/default.nix
    outputs.homeManagerModules.music.spotify

    # Shell - See ../../modules/home-manager/shell/default.nix
    outputs.homeManagerModules.shell.git
    outputs.homeManagerModules.shell.starship
    outputs.homeManagerModules.shell.zsh

    # Terminal - See ../../modules/home-manager/terminal/default.nix
    # outputs.homeManagerModules.terminal.kitty
    outputs.homeManagerModules.terminal.tmux
    outputs.homeManagerModules.terminal.wezterm
    outputs.homeManagerModules.terminal.zellij

    # Utils - See ../../modules/home-manager/utils/default.nix
    outputs.homeManagerModules.utils.age

    # ZSH - See ./zsh.nix
    ./zsh.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  colorScheme = inputs.nix-colors.colorSchemes."atelier-cave";

  home = {
    username = "yomi";
    homeDirectory = "/home/yomi";
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
