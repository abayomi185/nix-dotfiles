{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Apps - See ../../modules/home-manager/apps/default.nix
    outputs.homeManagerModules.apps.bat
    outputs.homeManagerModules.apps.btop
    outputs.homeManagerModules.apps.jq
    outputs.homeManagerModules.apps.k9s
    outputs.homeManagerModules.apps.neovim
    outputs.homeManagerModules.apps.ripgrep
    outputs.homeManagerModules.apps.vscode

    # Dev - See ../../modules/home-manager/dev/default.nix
    outputs.homeManagerModules.dev.rust
    outputs.homeManagerModules.dev.zig
    outputs.homeManagerModules.dev.nodejs

    # Shell - See ../../modules/home-manager/shell/default.nix
    outputs.homeManagerModules.shell.fzf
    outputs.homeManagerModules.shell.git
    outputs.homeManagerModules.shell.starship
    outputs.homeManagerModules.shell.zsh

    # Terminal - See ../../modules/home-manager/terminal/default.nix
    outputs.homeManagerModules.terminal.wezterm
    outputs.homeManagerModules.terminal.zellij

    # Utils - See ../../modules/home-manager/utils/default.nix
    outputs.homeManagerModules.utils.age

    # ZSH (custom) - See ./zsh.nix
    ./zsh.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
    ];

    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "yomi";
    homeDirectory = "/Users/yomi";
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
