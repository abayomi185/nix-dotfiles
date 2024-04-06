{hostConfig, ...}: {
  # Common configuration for Zsh
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history.size = hostConfig.programs.zsh.history.size or 10000;

    shellAliases =
      {
        la = "ls -la";
        check = "nix flake check";
        update = "sudo nixos-rebuild switch";
        garbage = "sudo nix-collect-garbage --delete-older-than";
        develop = "nix develop -c $SHELL";
      }
      // hostConfig.programs.zsh.shellAliases;

    # zshrc equivalent
    initExtra = hostConfig.programs.zsh.initExtra or "";

    # zshenv equivalent
    envExtra = hostConfig.programs.zsh.envExtra or "";

    # zprofile equivalent
    profileExtra = hostConfig.programs.zsh.profileExtra or "";

    zplug = {
      enable = true;
      plugins =
        [
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
        ]
        ++ hostConfig.programs.zsh.zplug.plugins;
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
