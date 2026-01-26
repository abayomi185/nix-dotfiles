{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    unstable.opencode
  ];

  # Set up symlink to opencode.jsonc
  xdg.configFile."opencode/opencode.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/dev/opencode/opencode.jsonc";
}
