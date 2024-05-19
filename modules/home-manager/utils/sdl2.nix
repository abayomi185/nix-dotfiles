{pkgs, ...}: {
  home.packages = with pkgs; [SDL2];
}
