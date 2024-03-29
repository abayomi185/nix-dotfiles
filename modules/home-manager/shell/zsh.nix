{
  programs = {
    zsh = {
      enable = true;

      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history.size = 10000;

      shellAliases = {
        la = "ls -la";
        check = "nix flake check";
        update = "sudo nixos-rebuild switch";
      };

      # zshrc equivalent
      initExtra = ''
      '';

      # zshenv equivalent
      envExtra = ''
        # export PATH=$HOME/bin:$PATH
        # Other environment variables or initialization commands
      '';

      # zprofile equivalent
      profileExtra = ''
      '';

      zplug = {
        enable = true;
        plugins = [
          { name = "plugins/git"; tags = [ "from:oh-my-zsh" ]; }
          { name = "plugins/fzf"; tags = [ "from:oh-my-zsh" ]; }
          { name = "plugins/ripgrep"; tags = [ "from:oh-my-zsh" ]; }
          { name = "plugins/vi-mode"; tags = [ "from:oh-my-zsh" ]; }
          # { name = "jeffreytse/zsh-vi-mode"; }
        ];
      };
    };
  };

}
