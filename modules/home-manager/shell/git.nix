{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Yomi Ikuru";
    userEmail = "captyomjnr@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };

    ignores = [".DS_Store" ".direnv/"];
  };

  # Add lazygit
  home.packages = with pkgs; [unstable.lazygit bfg-repo-cleaner];
}
