{
  config,
  pkgs,
  ...
}: {
  # gtk = {
  #   enable = true;
  #   font = {
  #     package = pkgs.nerdfonts.override {fonts = ["Mononoki"];};
  #     name = "Mononoki Nerd Font Regular";
  #     size = 18;
  #   };
  #   iconTheme = {
  #     package = pkgs.catppuccin-papirus-folders.override {
  #       flavor = "mocha";
  #       accent = "peach";
  #     };
  #     name = "Papirus-Dark";
  #   };
  #   theme = {
  #     package = pkgs.catppuccin-gtk.override {
  #       accents = ["peach"];
  #       size = "standard";
  #       variant = "mocha";
  #     };
  #     name = "Catppuccin-Mocha-Standard-Peach-Dark";
  #   };
  # };

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Macchiato-Compact-Pink-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = ["pink"];
        size = "compact";
        tweaks = ["rimless" "black"];
        variant = "macchiato";
      };
    };
  };

  # Now symlink the `~/.config/gtk-4.0/` folder declaratively:
  xdg.configFile = {
    "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };
}
