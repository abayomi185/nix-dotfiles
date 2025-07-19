# See common config here: ../../modules/home-manager/shell/zsh.nix
# WARN: Ensure that a `.zshrc.zwc` does not exist or this config won't work - this is a compiled zshrc file
{pkgs, ...}: {
  # Common configuration for Zsh
  programs.zsh = {
    enable = true;

    extendedShellAliases = {
      update = "sudo darwin-rebuild switch";
    };

    # zshrc equivalent
    initExtra = ''
    '';

    # zshenv equivalent
    envExtra = ''
      # Cargo
      . "$HOME/.cargo/env"

      # dotfiles
      alias config='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'

      # ESP-IDF things
      alias get_esprs='. $HOME/export-esp.sh'

      export SAM_CLI_TELEMETRY=0

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

      alias python=python3
    '';

    # zprofile equivalent
    profileExtra = ''
      # LANG config - fixes issues with SSH and tmux
      export LANG="en_US.UTF-8"

      export XDG_CONFIG_HOME="$HOME/.config"

      #To allow Multi-threading scripts macOS
      export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "virtualenv"
        "bundler"
        "fzf"
        # "direnv"
        "dotenv"
        "macos"
        "ruby"
        "sudo"
        # "autoupdate" not found
        # "zsh-autosuggestions"
      ];
    };

    plugins = [
      {
        name = "autoswitch_virtualenv";
        src = pkgs.fetchFromGitHub {
          owner = "MichaelAquilina";
          repo = "zsh-autoswitch-virtualenv";
          rev = "3.7.1";
          sha256 = "0bj4qnvq8mbznhv8yd3w2vxjfgbbap2w012lwj4pmn8l6g03s247";
        };
      }
    ];
  };

  programs.direnv.enable = true;
}
