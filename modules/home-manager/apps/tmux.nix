{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-plugins 'battery time'
          set -g @dracula-show-powerline true
          # set -g @dracula-show-farenheit false
          set -g @dracula-military-time true
        '';
      }
      # Tmux Session Manager
      {
        plugin = resurrect;
        extraConfig = ''
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
    ];
    # terminal = "tmux-256color";
    terminal = "xterm-256color";
    mouse = "on";
    keyMode = "vi";
    clock24 = true;
    defaultShell = "${pkgs.zsh}/bin/zsh";
    extraConfig = ''
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      # bind -T copy-mode-vi y send-keys -X copy-pipe "pbcopy"
      bind P paste-buffer
      # bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe "pbcopy"

      set -sa terminal-overrides ",xterm*:Tc"

      # Other examples:
      # set -g @plugin 'github_username/plugin_name'
      # set -g @plugin 'github_username/plugin_name#branch'
      # set -g @plugin 'git@github.com:user/plugin'
      # set -g @plugin 'git@bitbucket.com:user/plugin'

      # set -g default-terminal "screen-256color"
      # set -ga terminal-overrides ",xterm-256color:Tc"

      # Clipboard integration with OSC52
      # set -g set-clipboard on
      # allow other apps to passthrough sequences (including OSC52)
      # set -g allow-passthrough on
      # set -ag terminal-overrides "vte*:XT:Ms=\\E]52;c;%p2%s\\7,xterm*:XT:Ms=\\E]52;c;%p2%s\\7"

      # Bindings for more window/pane movement
      bind - switch-client -Tabove9
      bind -Tabove9 0 select-window -t:10
      bind -Tabove9 1 select-window -t:11
      bind -Tabove9 2 select-window -t:12
      bind -Tabove9 3 select-window -t:13
      bind -Tabove9 4 select-window -t:14
      bind -Tabove9 5 select-window -t:15
      bind -Tabove9 6 select-window -t:16
      bind -Tabove9 7 select-window -t:17
      bind -Tabove9 8 select-window -t:18
      bind -Tabove9 9 select-window -t:19
    '';
  };
}
