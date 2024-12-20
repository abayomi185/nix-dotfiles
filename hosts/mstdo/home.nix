{
  inputs,
  outputs,
  ...
}: {
  imports = [
    # Apps - See ../../modules/home-manager/apps/default.nix
    outputs.homeManagerModules.apps.bat
    outputs.homeManagerModules.apps.discord
    outputs.homeManagerModules.apps.jq
    outputs.homeManagerModules.apps.k9s
    outputs.homeManagerModules.apps.karabiner-elements
    outputs.homeManagerModules.apps.neovim-unstable
    outputs.homeManagerModules.apps.ripgrep
    outputs.homeManagerModules.apps.tree

    # Dev - See ../../modules/home-manager/dev/default.nix
    outputs.homeManagerModules.dev.github
    outputs.homeManagerModules.dev.kubectl
    outputs.homeManagerModules.dev.turso
    outputs.homeManagerModules.dev.xcodes

    # Monitoring - See ../../modules/home-manager/monitoring/default.nix
    outputs.homeManagerModules.monitoring.btop
    # outputs.homeManagerModules.monitoring.ncdu

    # Shell - See ../../modules/home-manager/shell/default.nix
    outputs.homeManagerModules.shell.fzf
    outputs.homeManagerModules.shell.git
    outputs.homeManagerModules.shell.starship
    outputs.homeManagerModules.shell.zsh

    # Terminal - See ../../modules/home-manager/terminal/default.nix
    outputs.homeManagerModules.terminal.zellij
    outputs.homeManagerModules.terminal.wezterm

    # Utils - See ../../modules/home-manager/utils/default.nix
    outputs.homeManagerModules.utils.age
    outputs.homeManagerModules.utils.ranger
    outputs.homeManagerModules.utils.sops
    outputs.homeManagerModules.utils.ssh-to-age

    # ZSH (custom) - See ./zsh.nix
    ./zsh.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      inputs.brew-nix.overlays.default
    ];

    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # homebrew = {
  #   enable = true;
  #   casks =
  # };

  home = {
    username = "yomi";
    homeDirectory = "/Users/yomi";
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
