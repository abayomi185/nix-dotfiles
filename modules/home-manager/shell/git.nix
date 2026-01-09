{pkgs, ...}: {
  programs.git = {
    enable = true;

    ignores = [".DS_Store" ".direnv/"];

    settings = {
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
      user = {
        name = "Yomi Ikuru";
        email = "captyomjnr@gmail.com";
      };
    };
  };

  programs.lazygit = {
    enable = true;
    package = pkgs.unstable.lazygit;
  };

  # Other git related tools
  home.packages = with pkgs; [bfg-repo-cleaner];
}
