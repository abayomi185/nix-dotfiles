{config, ...}: {
  # Set up symlink to karabiner config file
  xdg.configFile."karabiner/karabiner.json".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/yomi/nix-dotfiles/modules/darwin/apps/karabiner-elements/karabiner.json";
}
