{
  programs.hyprlock = {
    enable = true;

    # general = {};

    # images = [
    #   {}
    # ];

    labels = [
      # Time
      {
        text = "$TIME";
        color = "$foreground";
        #color = rgba(255, 255, 255, 0.6)
        font_size = 120;
        font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
        position = {
          x = 0;
          y = -300;
        };
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

    backgrounds = [
      {
        path = "/home/yomi/nix-dotfiles/modules/home-manager/desktop/wallpapers/grey.png";
        blur_size = 15;
        blur_passes = 2;
      }
    ];

    input-fields = [
      {
        size = {
          width = 250;
          height = 60;
        };
        outline_thickness = 2;
        dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
        dots_spacing = 0.2; # Scale of dots' absolute size, 0.0 - 1.0
        dots_center = true;
        outer_color = "rgba(0, 0, 0, 0)";
        inner_color = "rgba(0, 0, 0, 0.5)";
        font_color = "rgb(200, 200, 200)";
        fade_on_empty = false;
        # font_family = "JetBrains Mono Nerd Font Mono";
        placeholder_text = ''<i><span foreground="##cdd6f4">Input Password...</span></i>'';
        hide_input = false;
        position = {
          x = 0;
          y = -80;
        };
        halign = "center";
        valign = "center";
      }
    ];

    # extraConfig = ''
    # '';
  };
}
