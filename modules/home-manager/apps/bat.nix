{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [bat];

  programs.zsh.envExtra = lib.mkBefore "export BAT_THEME=GitHub";
}
