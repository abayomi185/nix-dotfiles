{config, ...}: {
  services.karabiner-elements = {
    enable = true;
  };

  # Set up symlink to config file
  xdg.configFile."karabiner/karabiner.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/darwin/apps/karabiner/karabiner.json";
}
