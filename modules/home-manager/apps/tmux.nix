{ pkgs, ... }: {
  home.packages = with pkgs; [ tmux ];
}
