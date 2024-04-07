{
  services.yabai = {
    enable = true;
    config = {
      window_placement = "second_child";
      window_opacity = "off";
      window_opacity_duration = 0.00;
      active_window_opacity = 1.0;
      auto_balance = "off";
      split_ratio = 0.50;
      mouse_modifier = "ctrl";
      mouse_action2 = "resize";
      mouse_action1 = "move";
      layout = "bsp";
      top_padding = 2;
      bottom_padding = 2;
      left_padding = 2;
      right_padding = 2;
      window_gap = 12;
    };

    extraConfig = builtins.readFile ./yabairc;
  };
}
