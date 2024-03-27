{ pkgs, ... }: {
  home.packages = with pkgs; [ brave spotify wezterm ];
}
