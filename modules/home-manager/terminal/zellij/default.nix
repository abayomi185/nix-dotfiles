{
  config,
  pkgs,
  ...
}: {
  programs.zellij = {
    enable = true;
    package = pkgs.unstable.zellij;
  };

  # Set up symlink to config file
  xdg.configFile."zellij/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/terminal/zellij/config.kdl";

  xdg.configFile."zellij/layouts/primary.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/terminal/zellij/primary-layout.kdl";
  xdg.configFile."zellij/layouts/primary.swap.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/terminal/zellij/layout.swap.kdl";

  xdg.configFile."zellij/layouts/secondary.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/terminal/zellij/secondary-layout.kdl";
  xdg.configFile."zellij/layouts/secondary.swap.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/terminal/zellij/base-layout.swap.kdl";

  xdg.configFile."zellij/layouts/tertiary.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/terminal/zellij/tertiary-layout.kdl";
  xdg.configFile."zellij/layouts/tertiary.swap.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/terminal/zellij/base-layout.swap.kdl";

  xdg.configFile."zellij/layouts/quaternary.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/terminal/zellij/quaternary-layout.kdl";
  xdg.configFile."zellij/layouts/quaternary.swap.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/terminal/zellij/base-layout.swap.kdl";
}
