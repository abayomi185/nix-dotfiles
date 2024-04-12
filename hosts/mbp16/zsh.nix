# See common config here: ../../modules/home-manager/shell/zsh.nix
{
  # Common configuration for Zsh
  programs.zsh = {
    enable = true;
    isDarwin = true;

    zplug = {
      plugins = [
        {
          name = "plugins/virtualenv";
          tags = ["from:oh-my-zsh"];
        }
        {
          name = "plugins/bundler";
          tags = ["from:oh-my-zsh"];
        }
        {
          name = "plugins/fzf";
          tags = ["from:oh-my-zsh"];
        }

        # { name = "plugins/ripgrep"; tags = [ "from:oh-my-zsh" ]; }

        {
          name = "plugins/dotenv";
          tags = ["from:oh-my-zsh"];
        }
        {
          name = "plugins/macos";
          tags = ["from:oh-my-zsh"];
        }
        {
          name = "plugins/ruby";
          tags = ["from:oh-my-zsh"];
        }
        {
          name = "plugins/sudo";
          tags = ["from:oh-my-zsh"];
        }
        {
          name = "plugins/autoupdate";
          tags = ["from:oh-my-zsh"];
        }
        {
          name = "plugins/zsh-autosuggestions";
          tags = ["from:oh-my-zsh"];
        }

        {name = "MichaelAquilina/zsh-autoswitch-virtualenv";}

      ];
    };
  };

  programs.direnv.enable = false;
}
