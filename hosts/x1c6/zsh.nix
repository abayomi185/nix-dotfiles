{
  programs.zsh = {
    shellAliases = {
      # open = "dolphin";
    };

    # zshrc equivalent
    # initextra = ''
    # '';

    # zshenv equivalent
    envExtra = ''
      export lang=en_us.utf-8
      # export path=$home/bin:$path
      # other environment variables or initialization commands
    '';

    # zprofile equivalent
    # profileextra = ''
    # '';

    zplug = {
      plugins = [
        # { name = "plugins/fzf"; tags = [ "from:oh-my-zsh" ]; }
        # { name = "plugins/ripgrep"; tags = [ "from:oh-my-zsh" ]; }
        # { name = "jeffreytse/zsh-vi-mode"; }
      ];
    };
  };
}
