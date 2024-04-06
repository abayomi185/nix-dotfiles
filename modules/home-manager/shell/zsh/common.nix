{
  # Common configuration for Zsh
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
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
    initExtra = "";

    # zshenv equivalent
    envExtra = "";

    # zprofile equivalent
    profileExtra = "";

    zplug = {
      enable = true;
      plugins = [
        {
          name = "plugins/git";
          tags = ["from:oh-my-zsh"];
        }
        {
          name = "plugins/vi-mode";
          tags = ["from:oh-my-zsh"];
        }
        {
          name = "plugins/direnv";
          tags = ["from:oh-my-zsh"];
        }
      ];
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
