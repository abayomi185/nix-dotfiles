{inputs, ...}: {
  imports = [
    # inputs.hyprland.homeManagerModules.default # To use hyprland flake from the hyprland repo

    ../rofi
    ../waybar

    # ../mako.nix
    # ../swappy.nix
    # ../wl-common.nix

    # Hypr
    ./hyprlock.nix
    ./hypridle.nix
    ./hyprpaper.nix
    ./hyprcursor.nix

    # GTK
    ../gtk.nix

    # Services
    ../services/batsignal.nix
    ../services/swayosd.nix
    ../services/swaync.nix
    ../services/playerctl.nix
    ../services/xdg.nix # XDG Desktop Portal

    # Packages
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
        # Spacer
        "hypridle"
        "hyprpaper"
        "hyprctl setcursor phinger-cursors-dark 24"
        # Spacer
        "[workspace 1 silent] discord"
        "[workspace 2 silent] spotify"
        "[workspace 3 silent] brave"
        "[workspace 4 silent] wezterm"
        # Spacer
        "nm-applet --indicator"
      ];

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 0;
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_forever = false;
        workspace_swipe_invert = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_cancel_ratio = 0.1;
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
        natural_scroll = false; # For the trackpoint
        touchpad = {
          natural_scroll = true;
          tap-to-click = false;
          clickfinger_behavior = true;
          scroll_factor = 0.2;
        };
        kb_options = "caps:super,shift:both_capslock_cancel,ctrl:swap_lalt_lctl";
      };

      decoration = {
        rounding = 10;
        drop_shadow = false;
        blur = {
          enabled = false;
        };
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

      windowrulev2 = [
        # make Brave PiP window floating and sticky
        "float, title:^(Picture-in-picture)$"
        "pin, title:^(Picture-in-picture)$"

        "float, class:^(org.wezfurlong.wezterm)$"
        "tile, class:^(org.wezfurlong.wezterm)$"

        # # idle inhibit while watching videos
        # "idleinhibit focus, class:^(mpv|.+exe|celluloid)$"
        # "idleinhibit focus, class:^(firefox)$, title:^(.*YouTube.*)$"
        # "idleinhibit fullscreen, class:^(firefox)$"
      ];

      misc = {
        focus_on_activate = true; # focus on window when it's activated
      };

      # env = [
      #   "HYPRCURSOR_THEME,phinger-cursors-dark"
      #   "HYPRCURSOR_SIZE,24"
      # ];

      bind = [
        "$mod,        Return, exec, wezterm"
        # "$mod,        Return, exec, [float;tile] wezterm start --always-new-process"
        "$mod_SHIFT,  SPACE,  exec, rofi"
        "$mod,        SPACE,  exec, rofi -show drun -show-icons"

        "$mod, T, exec, konsole"
        "$mod, B, exec, brave"
        "$mod, D, exec, discord"
        "$mod, M, exec, spotify"

        "$mod, O, exec, killall -SIGUSR1 .waybar-wrapped"

        "CONTROL_ALT, Q, exec, loginctl lock-session"

        "$mod_CONTROL, 3, exec, grimblast --notify copysave" # Whole screen
        "$mod_CONTROL, 4, exec, grimblast --notify copysave active" # Active window
        "$mod_CONTROL, 5, exec, grimblast --notify copysave area" # Area selection
        "$mod, Print, exec, GRIMBLAST_EDITOR=drawing grimblast --notify edit" # Open in image editor

        "$mod_SHIFT, I, togglesplit,"
        "$mod, F, fullscreen, 1"
        "$mod_CONTROL, F, fullscreen, 0"

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
        "$mod_CONTROL, l, workspace, e+1"
        "$mod_CONTROL, h, workspace, e-1"
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # bindm = ${modifier},mouse:272,movewindow
        # bindm = ${modifier},mouse:273,resizewindow

        # "ALT, Tab, cyclenext"
        # "ALT, Tab, bringactivetotop"

        "$mod,        backslash, exec, gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Macchiato-Compact-Pink-Dark' && gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' && gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'"
        "$mod_SHIFT,  backslash, exec, gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Macchiato-Compact-Pink-Light' && gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' && gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Light'"
      ];

      # repeat when held
      binde = [
        "$mod, left,  resizeactive, -40 0"
        "$mod, right, resizeactive, 40 0"
        "$mod, up,    resizeactive, 0 -40"
        "$mod, down,  resizeactive, 0 40"

        # ", XF86AudioRaiseVolume,  exec, wpctl set-mute @DEFAULT_AUDIO_SINK@   0     ; wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        # ", XF86AudioLowerVolume,  exec, wpctl set-mute @DEFAULT_AUDIO_SINK@   0     ; wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"
        # ", XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SINK@   toggle"
        # ", XF86AudioMicMute,      exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        # ", XF86MonBrightnessUp,   exec, brightnessctl --min-value=10 s +5%"
        # ", XF86MonBrightnessDown, exec, brightnessctl --min-value=10 s 5%-"

        ", XF86AudioRaiseVolume,  exec, wpctl set-mute @DEFAULT_AUDIO_SINK@   0     ; swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume,  exec, wpctl set-mute @DEFAULT_AUDIO_SINK@   0     ; swayosd-client --output-volume lower"
        ", XF86AudioMute,         exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioMicMute,      exec, swayosd-client --input-volume mute-toggle"

        ", XF86MonBrightnessUp,   exec, swayosd-client --brightness +5"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness -5"
      ];

      # mouse binds
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # g
      bindl = [
        ", switch:Lid Switch, exec, hyprlock"
      ];
    };
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SCREENSHOTS_DIR = "$HOME/Pictures/screenshots";
    # MOZ_ENABLE_WAYLAND = "1";
  };
}
