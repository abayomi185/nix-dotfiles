{...}: {
  # home.packages = with pkgs; [wezterm];

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    # extraConfig = builtins.readFile ./wezterm.lua; # symlink preferred
  };

  # Set up symlink to wezterm.lua
  xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
}
