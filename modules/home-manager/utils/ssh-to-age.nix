{pkgs, ...}: {
  home.packages = with pkgs; [ssh-to-age];
}
