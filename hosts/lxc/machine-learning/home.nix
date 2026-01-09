{
  config,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    outputs.homeManagerModules.terminal.zellij
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  home.username = "ml";
  home.homeDirectory = "/home/ml";
  home.packages = with pkgs; [
    age
    alejandra
    nil
    nixpkgs-fmt
    btop
    lazygit
    llama-cpp
    unstable.llama-swap
    lua-language-server
    nodejs_22
    stylua
    selene
    ssh-to-age
    uv
  ];

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

    settings = {
      user = {
        name = "yomi+git_homelab_lxc_ml_ml@yomitosh.com";
        email = "Yomi Ikuru";
      };
    };
  };

  programs.starship = {
    enable = true;

    settings = {
      nix_shell = {
        disabled = false;
        impure_msg = "";
        symbol = "";
        format = "[$symbol$state]($style) ";
      };
      shlvl = {
        disabled = false;
        symbol = "λ ";
      };
    };
  };

  xdg.configFile."llama-swap/config.yaml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/hosts/lxc/machine-learning/configs/llama-swap.yaml";

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
  home.stateVersion = "25.05";
}
