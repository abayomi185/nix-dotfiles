{ pkgs, ... }: {
  home.packages = with pkgs; [ wezterm ];

  home.file.".config/wezterm/wezterm.lua".text = builtins.readFile ./wezterm.lua;
}
