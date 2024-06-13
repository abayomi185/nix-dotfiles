{pkgs, ...}: {
  home.packages = with pkgs; [turso-cli];
}
