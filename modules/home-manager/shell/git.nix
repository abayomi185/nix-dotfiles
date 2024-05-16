{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Yomi Ikuru";
    userEmail = "captyomjnr@gmail.com";
  };

  # Add lazygit
  home.packages = with pkgs; [lazygit bfg-repo-cleaner];
}
