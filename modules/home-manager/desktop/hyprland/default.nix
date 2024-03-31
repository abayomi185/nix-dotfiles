{ inputs, pkgs, ... }: {
  imports = [
    inputs.hyprlock.homeManagerModules.default
    inputs.hypridle.homeManagerModules.default

    # ../rofi # Not working
    ../waybar
    #
    # ../mako.nix
    # ../swappy.nix
    # ../wl-common.nix

    ./hyprlock.nix
    ./packages.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
    ];

    settings = {
      "$mod" = "SUPER";

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 0;
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_forever = true;
        workspace_swipe_invert = false;
      };

      input = {
        # kb_layout = "gb";
        # follow_mouse = 2;
        repeat_rate = 50;
        repeat_delay = 300;
      };
    };
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # MOZ_ENABLE_WAYLAND = "1";
  };
}
