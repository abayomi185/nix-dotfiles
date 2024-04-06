{
  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh = {
    enable = true; # Important!

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # zshrc equivalent
    initExtra = ''
      # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
      # [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      export ZSH=~/.oh-my-zsh
      source $ZSH/oh-my-zsh.sh

      export UPDATE_ZSH_DAYS=30

      eval "$(fnm env --use-on-cd)"

      export PATH="/usr/local/opt/util-linux/bin:$PATH"
      export PATH="/usr/local/opt/util-linux/sbin:$PATH"

      export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

      # export PATH="$HOME/.rbenv/shims:$PATH"
      # export PATH="/usr/local/opt/ruby/bin:$PATH"
      eval "$(rbenv init - zsh)"

      eval "$(starship init zsh)"

      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
      export FZF_DEFAULT_OPTS="--extended"

      # pnpm
      export PNPM_HOME="/Users/yomi/Library/pnpm"
      export PATH="$PNPM_HOME:$PATH"
      # pnpm end
    '';

    # zshenv equivalent
    envExtra = ''
      # export LANG=en_US.UTF-8

      # Cargo
      . "$HOME/.cargo/env"

      # dotfiles
      alias config='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'

      # ESP-IDF things
      alias get_esprs='. $HOME/export-esp.sh'

      export SAM_CLI_TELEMETRY=0

      alias python=python3
      alias pip=pip3

      alias k=kubectl

      alias vi="nvim"

      alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

      alias develop="nix develop -c $SHELL"
    '';

    # zprofile equivalent
    profileExtra = ''
      # LANG config
      # Fixes issues with SSH and tmux
      export LANG="en_US.UTF-8"

      # Terminal color config
      export TERM=xterm-256color

      export THEOS=~/theos

      export PATH="$HOME/.gem/ruby/2.6.3/bin:$PATH"

      export PATH="/usr/local/opt/python/libexec/bin:/usr/local/sbin:$PATH"

      export XDG_CONFIG_HOME="$HOME/.config"

      # Make the terminal safe
      set -o noclobber
      #alias cp='cp -i'
      #alias mv='mv -i'

      # Show neofetch on launch
      #neofetch

      #export VIRTUALENVWRAPPER_PYTHON=`which python`
      #export VIRTUALENVWRAPPER_VIRTUALENV=`which virtualenv`

      # Virtualenvwrapper things
      #export WORKON_HOME=$HOME/.virtualenvs
      #export PROJECT_HOME=$HOME/Devel
      #source /usr/local/bin/virtualenvwrapper.sh

      #Pico things
      export PICO_SDK_PATH="$HOME/pico/pico-sdk"

      #To allow Multi-threading scripts macOS
      export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

      #Disable Homebrew auto update
      export HOMEBREW_NO_AUTO_UPDATE=1

      # Homebrew Apple Silicon
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';

    zplug = {
      enable = true;
      plugins = [
        { name = "plugins/git"; tags = [ "from:oh-my-zsh" ]; }
        { name = "plugins/virtualenv"; tags = [ "from:oh-my-zsh" ]; }
        { name = "plugins/bundler"; tags = [ "from:oh-my-zsh" ]; }
        { name = "plugins/vi-mode"; tags = [ "from:oh-my-zsh" ]; }
        { name = "plugins/fzf"; tags = [ "from:oh-my-zsh" ]; }

        # { name = "plugins/ripgrep"; tags = [ "from:oh-my-zsh" ]; }

        { name = "plugins/dotenv"; tags = [ "from:oh-my-zsh" ]; }
        { name = "plugins/direnv"; tags = [ "from:oh-my-zsh" ]; }
        { name = "plugins/macos"; tags = [ "from:oh-my-zsh" ]; }
        { name = "plugins/ruby"; tags = [ "from:oh-my-zsh" ]; }
        { name = "plugins/sudo"; tags = [ "from:oh-my-zsh" ]; }
        { name = "plugins/autoupdate"; tags = [ "from:oh-my-zsh" ]; }

        { name = "MichaelAquilina/zsh-autoswitch-virtualenv"; }
      ];
    };
  };

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}

# zmodload zsh/zprof

# test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# plugins=(
#     #zsh-nvm
#     virtualenv
#     git
#     bundler
#     dotenv
#     macos
#     #rake
#     #rbenv
#     ruby
#     zsh-autosuggestions
#     zsh-syntax-highlighting
#     sudo
#     #zsh-apple-touchbar
#     autoswitch_virtualenv
#     autoupdate
# )
