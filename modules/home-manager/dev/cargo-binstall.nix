{pkgs, ...}: {
  home.packages = with pkgs; [cargo-binstall];
}
