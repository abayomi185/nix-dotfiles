{pkgs, ...}: {
  home.packages = with pkgs; [sops];
}
