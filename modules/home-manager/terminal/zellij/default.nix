{config, ...}: {
  programs.zellij = {
    enable = true;
  };

  # Set up symlink to config file
  xdg.configFile."zellij/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/terminal/zellij/config.kdl";
}
