{
  services.hyprpaper = {
    enable = true;

    splash = true;

    preloads = [
      "~/nix-dotfiles/modules/home-manager/desktop/wallpapers/modern_grey.png"
    ];
    wallpapers = [
      "eDP-1,~/nix-dotfiles/modules/home-manager/desktop/wallpapers/modern_grey.png"
    ];
  };
}
