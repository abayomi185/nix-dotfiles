{pkgs, ...}: {
  home.packages = with pkgs; [home-assistant-cli];
}
