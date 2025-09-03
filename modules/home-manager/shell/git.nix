{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Yomi Ikuru";
    userEmail = "captyomjnr@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      core.pager = "bat --paging=always";
      push.autoSetupRemote = true;

      merge = {
        tool = "diffview";
      };
      mergetool = {
        diffview.cmd = ''nvim -n +DiffviewOpen "$MERGE"'';
        keepBackup = false;
        prompt = false;
      };
    };

    ignores = [".DS_Store" ".direnv/"];
  };

  programs.lazygit = {
    enable = true;
    package = pkgs.unstable.lazygit;
  };

  # Other git related tools
  home.packages = with pkgs; [bfg-repo-cleaner];
}
