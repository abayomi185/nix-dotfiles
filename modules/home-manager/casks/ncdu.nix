{pkgs, ...}: {
  home.packages = with pkgs; [
    brewCasks.ncdu
  ];
}
