{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-ssh
      vscodevim.vim
      github.copilot
      github.copilot-chat
      eamodio.gitlens
      donjayamanne.githistory
      emroussel.atomize-atom-one-dark-theme
      vscode-icons-team.vscode-icons
      oderwat.indent-rainbow
      alefragnani.bookmarks
      kamikillerto.vscode-colorize
      esbenp.prettier-vscode
    ];
    userSettings = {};
    keybindings = [];
  };
}
