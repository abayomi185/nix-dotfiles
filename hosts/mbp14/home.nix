{
  inputs,
  outputs,
  pkgs,
  ...
}: let
  secretsPath = builtins.toString inputs.mysecrets;
in {
  imports = [
    # Apps - See ../../modules/home-manager/apps/default.nix
    outputs.homeManagerModules.apps.bat
    outputs.homeManagerModules.apps.discord
    outputs.homeManagerModules.apps.jq
    outputs.homeManagerModules.apps.k9s
    outputs.homeManagerModules.apps.karabiner-elements
    outputs.homeManagerModules.apps.neovim-unstable
    # outputs.homeManagerModules.apps.openscad
    outputs.homeManagerModules.apps.ripgrep
    outputs.homeManagerModules.apps.tree
    outputs.homeManagerModules.apps.vscode

    # Casks - See ../../modules/home-manager/casks/default.nix
    # outputs.homeManagerModules.casks.ncdu

    # Dev - See ../../modules/home-manager/dev/default.nix
    outputs.homeManagerModules.dev.cargo-bins
    outputs.homeManagerModules.dev.github
    outputs.homeManagerModules.dev.go
    outputs.homeManagerModules.dev.kubectl
    outputs.homeManagerModules.dev.nodejs
    # outputs.homeManagerModules.dev.python
    outputs.homeManagerModules.dev.rust
    outputs.homeManagerModules.dev.turso
    outputs.homeManagerModules.dev.zig

    # Monitoring - See ../../modules/home-manager/monitoring/default.nix
    outputs.homeManagerModules.monitoring.btop
    # outputs.homeManagerModules.monitoring.ncdu

    # Music - See ../../modules/home-manager/music/default.nix
    # outputs.homeManagerModules.music.spotify

    # Shell - See ../../modules/home-manager/shell/default.nix
    outputs.homeManagerModules.shell.fzf
    outputs.homeManagerModules.shell.git
    outputs.homeManagerModules.shell.starship
    outputs.homeManagerModules.shell.zsh

    # Terminal - See ../../modules/home-manager/terminal/default.nix
    outputs.homeManagerModules.terminal.ghostty
    outputs.homeManagerModules.terminal.wezterm
    outputs.homeManagerModules.terminal.zellij

    # Utils - See ../../modules/home-manager/utils/default.nix
    outputs.homeManagerModules.utils.age
    outputs.homeManagerModules.utils.pulseview
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

  home.packages = [
    pkgs.nixVersions.nix_2_22 # brew-nix input requires nix version > 2.19
  ];

  home = {
    username = "yomi";
    homeDirectory = "/Users/yomi";
  };

  sops = {
    age.sshKeyPaths = ["/home/yomi/.ssh/id_ed25519"];
    defaultSopsFile = "${secretsPath}/hosts/mba13/secrets.enc.yaml";
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
