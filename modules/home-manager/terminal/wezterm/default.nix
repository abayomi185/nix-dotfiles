{
  config,
  pkgs,
  ...
}: let
  nerdFont = pkgs.nerd-fonts.jetbrains-mono;
in {
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile."wezterm/font.lua".text = ''
    return {
      dirs = { "${nerdFont}/share/fonts/truetype/NerdFonts/JetBrainsMono" },
      family = "JetBrainsMono Nerd Font Mono",
    }
  '';

  # Set up symlink to wezterm.lua
  xdg.configFile."wezterm/wezterm.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/terminal/wezterm/wezterm.lua";
}
