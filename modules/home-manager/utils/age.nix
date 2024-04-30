{pkgs, ...}: {
  home.packages = with pkgs; [age];
}
