{
  config,
  pkgs,
  ...
}: let
  userDir =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/Application Support/Code/User"
    else "${config.xdg.configHome}/Code/User";
in {
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        ms-vscode-remote.remote-ssh
        vscodevim.vim
        github.copilot
        eamodio.gitlens
        donjayamanne.githistory
        emroussel.atomize-atom-one-dark-theme
        vscode-icons-team.vscode-icons
        oderwat.indent-rainbow
        alefragnani.bookmarks
        kamikillerto.vscode-colorize
        esbenp.prettier-vscode
      ];
    };
  };

  # Symlinks for VSCode settings and keybindings
  home.file."${userDir}/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/apps/vscode/settings.json";

  home.file."${userDir}/keybindings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/apps/vscode/keybindings.json";
}
