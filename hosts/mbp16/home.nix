{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  imports = [
    # Apps - See ../../modules/home-manager/apps/default.nix
    outputs.homeManagerModules.apps.neovim
    # Shell - See ../../modules/home-manager/shell/default.nix
    outputs.homeManagerModules.shell.zsh_darwin
    outputs.homeManagerModules.shell.starship
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
