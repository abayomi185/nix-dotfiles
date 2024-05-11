{
  services.hyprpaper = {
    enable = true;

    settings = {
      splash = true;

      preload = [
        "~/nix-dotfiles/modules/home-manager/desktop/wallpapers/modern_grey.png"
      ];
      wallpaper = [
        "eDP-1,~/nix-dotfiles/modules/home-manager/desktop/wallpapers/modern_grey.png"
      ];
    };
  };
}
