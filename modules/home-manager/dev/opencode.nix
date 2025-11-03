{pkgs, ...}: {
  home.packages = with pkgs; [
    unstable.opencode
  ];
}
