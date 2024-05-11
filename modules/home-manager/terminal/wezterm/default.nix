{
  config,
  pkgs,
  ...
}: {
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    # package = pkgs.wezterm-nightly;
    # extraConfig = builtins.readFile ./wezterm.lua; # symlink preferred
  };

  # Set up symlink to wezterm.lua
  xdg.configFile."wezterm/wezterm.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/terminal/wezterm/wezterm.lua";
}
