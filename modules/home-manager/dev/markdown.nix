{pkgs, ...}: {
  home.packages = with pkgs; [
    marksman
    markdown-oxide
  ];
}
