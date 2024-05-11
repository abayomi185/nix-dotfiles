{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
      };

      # images = [
      #   {}
      # ];

      label = [
        # Time
        {
          text = "$TIME";
          color = "$foreground";
          #color = rgba(255, 255, 255, 0.6)
          font_size = 120;
          font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
          position = "0, -300";
          halign = "center";
          valign = "top";
        }
        # User
        # {
        #   text = "Hi there, $USER";
        #   color = "$foreground";
        #   #color = rgba(255, 255, 255, 0.6)
        #   font_size = 25;
        #   font_family = "JetBrains Mono Nerd Font Mono";
        #   position = {
        #     x = 0;
        #     y = -20;
        #   };
        #   halign = "center";
        #   valign = "center";
        # }
      ];

      background = [
        {
          path = "/home/yomi/nix-dotfiles/modules/home-manager/desktop/wallpapers/grey.png";
          blur_size = 15;
          blur_passes = 2;
        }
      ];

      input-field = [
        {
          size = "250, 60";
          position = "0, -80";
          halign = "center";
          valign = "center";
          # font_family = "JetBrains Mono Nerd Font Mono";
          placeholder_text = ''<i><span foreground="##cdd6f4">Input Password...</span></i>'';
          outer_color = "rgba(0, 0, 0, 0)";
          inner_color = "rgba(0, 0, 0, 0.5)";
          font_color = "rgb(200, 200, 200)";
          outline_thickness = 2;
          dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
          dots_spacing = 0.2; # Scale of dots' absolute size, 0.0 - 1.0
          dots_center = true;
          fade_on_empty = false;
          hide_input = false;
        }
      ];
    };

    # extraConfig = ''
    # '';
  };
}
