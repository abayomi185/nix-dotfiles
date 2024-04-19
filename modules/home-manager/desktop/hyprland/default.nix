{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprlock.homeManagerModules.default
    inputs.hypridle.homeManagerModules.default

    ../rofi
    ../waybar

    # ../mako.nix
    # ../swappy.nix
    # ../wl-common.nix

    # ./hyprlock.nix
    # ./hypridle.nix
    ./packages.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    plugins = [
      # inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
    ];

    extraConfig = ''
    '';

    settings = {
      "$mod" = "SUPER";

      monitor = ",preferred,auto,1.25";

      exec-once = [
        "waybar"
      ];

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 0;
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_forever = true;
        workspace_swipe_invert = true;
        workspace_swipe_fingers = 3;
      };

      xwayland = {
        force_zero_scaling = true;
        use_nearest_neighbor = false;
      };

      input = {
        # kb_layout = "us";
        # follow_mouse = 2;
        repeat_rate = 50;
        repeat_delay = 300;
        natural_scroll = true;
        touchpad = {
          natural_scroll = true;
          tap-to-click = false;
          clickfinger_behavior = true;
          scroll_factor = 0.2;
        };
        kb_options = "caps:super,shift:both_capslock_cancel,ctrl:swap_lalt_lctl";
      };

      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 5, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      windowrule = [
        "float, Rofi"
      ];

      bind = [
        "$mod,        Return, exec, wezterm"
        "$mod_SHIFT,  Return, exec, rofi-launcher"
        "$mod,        SPACE,  exec, rofi -show drun -show-icons"

        "$mod, T, exec, konsole"
        "$mod, W, exec, brave"
        "$mod, D, exec, discord"
        "$mod, M, exec, spotify"

        "$mod_SHIFT, I, togglesplit,"
        "$mod, F, fullscreen,1"
        "$mod_CONTROL, F, fullscreen,0"

        "$mod_SHIFT, F,     togglefloating,"
        "$mod_SHIFT, C,     exit,"
        "$mod_SHIFT, left,  movewindow, l"
        "$mod_SHIFT, right, movewindow, r"
        "$mod_SHIFT, up,    movewindow, u"
        "$mod_SHIFT, down,  movewindow, d"
        "$mod_SHIFT, h,     movewindow, l"
        "$mod_SHIFT, l,     movewindow, r"
        "$mod_SHIFT, k,     movewindow, u"
        "$mod_SHIFT, j,     movewindow, d"

        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"

        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod_SHIFT, SPACE, movetoworkspace, special"
        # "$mod, SPACE, togglespecialworkspace"

        "$mod_SHIFT, 1, movetoworkspace, 1"
        "$mod_SHIFT, 2, movetoworkspace, 2"
        "$mod_SHIFT, 3, movetoworkspace, 3"
        "$mod_SHIFT, 4, movetoworkspace, 4"
        "$mod_SHIFT, 5, movetoworkspace, 5"
        "$mod_SHIFT, 6, movetoworkspace, 6"
        "$mod_SHIFT, 7, movetoworkspace, 7"
        "$mod_SHIFT, 8, movetoworkspace, 8"
        "$mod_SHIFT, 9, movetoworkspace, 9"
        "$mod_SHIFT, 0, movetoworkspace, 10"

        "$mod_CONTROL, right, workspace, e+1"
        "$mod_CONTROL, left, workspace, e-1"
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # bindm = ${modifier},mouse:272,movewindow
        # bindm = ${modifier},mouse:273,resizewindow

        # "ALT, Tab, cyclenext"
        # "ALT, Tab, bringactivetotop"
      ];

      # repeat when held
      binde = [
        "$mod, left,  resizeactive, -40 0"
        "$mod, right, resizeactive, 40 0"
        "$mod, up,    resizeactive, 0 -40"
        "$mod, down,  resizeactive, 0 40"

        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      # mouse binds
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # MOZ_ENABLE_WAYLAND = "1";
  };
}
