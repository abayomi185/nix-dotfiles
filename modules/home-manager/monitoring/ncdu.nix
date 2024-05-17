{pkgs, ...}: {
  home.packages = with pkgs; [
    ncdu
  ];
}
