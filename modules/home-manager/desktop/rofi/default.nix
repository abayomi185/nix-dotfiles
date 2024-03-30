{ config, pkgs, ... }:
let
  rofiTheme = (import ./theme.nix { inherit pkgs config; }).theme;
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    theme = rofiTheme;
    terminal = "${pkgs.wezterm}/bin/wezterm";

    extraConfig = {
      modi = "drun";
      show-icons = true;
      drun-display-format = "{icon} {name}";
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "   Apps ";
      sidebar-mode = true;
    };
  };

  home.packages = with pkgs; [ bemoji ];
}
