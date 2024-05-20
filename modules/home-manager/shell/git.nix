{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Yomi Ikuru";
    userEmail = "captyomjnr@gmail.com";

    config = {
      init.defaultBranch = "main";
    };
  };

  # Add lazygit
  home.packages = with pkgs; [lazygit bfg-repo-cleaner];
}
