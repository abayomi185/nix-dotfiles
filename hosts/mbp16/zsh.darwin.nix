{lib,...}:{
  programs.zsh = {
    # enableCompletion = true; # Default
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
    enableSyntaxHighlighting = true;

    # zshrc equivalent
    shellInit = ''
      # zmodload zsh/zprof
      # test -e "''${HOME}/.iterm2_shell_integration.zsh" && source "''${HOME}/.iterm2_shell_integration.zsh"

      # eval "$(fnm env --use-on-cd)" # moved to loginShellInit

      export PATH="/usr/local/opt/util-linux/bin:$PATH"
      export PATH="/usr/local/opt/util-linux/sbin:$PATH"

      export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

      # export PATH="$HOME/.rbenv/shims:$PATH"
      # export PATH="/usr/local/opt/ruby/bin:$PATH"
      # eval "$(rbenv init - zsh)" # moved to loginShellInit

      # [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh # NOTE: Remember to delete the script
      # export FZF_DEFAULT_OPTS="--extended"
    '';

    # zshenv equivalent
    interactiveShellInit = ''
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

      alias la="ls -la"
      alias check="nix flake check"
      alias update="sudo darwin-rebuild switch"
      alias garbage="sudo nix-collect-garbage --delete-older-than"
      alias develop="nix develop -c $SHELL"
      alias batl="bat --theme=base16"
      alias batp="bat -P"

      alias txt="echo 'Hello, world!'"
    '';

    # zprofile equivalent
    loginShellInit = ''
      # LANG config - fixes issues with SSH and tmux
      export LANG="en_US.UTF-8"

      # Terminal color config
      export TERM=xterm-256color

      # export THEOS=~/theos # Theos path for iOS tweak development

      # export PATH="/usr/local/opt/python/libexec/bin:/usr/local/sbin:$PATH"

      export XDG_CONFIG_HOME="$HOME/.config"

      # Make the terminal safe
      set -o noclobber
      #alias cp='cp -i'
      #alias mv='mv -i'

      #Pico things
      export PICO_SDK_PATH="$HOME/pico/pico-sdk"

      #To allow Multi-threading scripts macOS
      export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

      #Disable Homebrew auto update
      export HOMEBREW_NO_AUTO_UPDATE=1

      # Homebrew Apple Silicon
      eval "$(/opt/homebrew/bin/brew shellenv)"
      
      # fnm
      eval "$(fnm env --use-on-cd)"

      # rbenv
      eval "$(rbenv init - zsh)"
    '';
    };
}
