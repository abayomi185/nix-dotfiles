{pkgs, ...}: {
  # home.packages = with pkgs; [
  #   vscode-fhs
  # ];
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-ssh
      vscodevim.vim
    ];
  };
}
