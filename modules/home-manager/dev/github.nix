# GitHub CLI
{pkgs, ...}: {
  home.packages = with pkgs; [gh github-copilot-cli];
}
