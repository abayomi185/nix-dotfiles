{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Yomi Ikuru";
    userEmail = "yomi@yomitosh.com";
  };

  # Add lazygit
  home.packages = with pkgs; [lazygit bfg-repo-cleaner];
}
