{
  pkgs,
  config,
  ...
}: let
  palette = config.colorScheme.palette;
in {
  programs.rofi = {
    enable = true;

    package = pkgs.rofi-wayland;

    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
    ];

    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg = mkLiteral "#${palette.base00}";
        background-color = mkLiteral "@bg";
      };

      "configuration" = {
        modi = "run,drun";
        show-icons = true;
        icon-theme = "Papirus";
        location = 0;
        font = "JetBrains Nerd Font 12";
        drun-display-format = "{icon} {name}";
        display-drun = "   Apps ";
        display-run = "   Run ";
        display-filebrowser = "   File ";
      };

      "window" = {
        width = mkLiteral "25%";
        transparency = "real";
        orientation = mkLiteral "vertical";
        border = mkLiteral "0 px";
        border-color = mkLiteral "#${palette.base0F}";
        border-radius = mkLiteral "10px";
      };

      "mainbox" = {
        children = map mkLiteral ["inputbar" "listview" "mode-switcher"];
      };

      # ELEMENT
      # -----------------------------------

      "element" = {
        padding = mkLiteral "8 14";
        text-color = mkLiteral "#${palette.base05}";
        border-radius = mkLiteral "5px";
      };

      "element selected" = {
        text-color = mkLiteral "#${palette.base01}";
        background-color = mkLiteral "#${palette.base0C}";
      };

      "element-text" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };

      "element-icon" = {
        size = mkLiteral "24px";
        background-color = mkLiteral "inherit";
        padding = mkLiteral "0 6 0 0";
        alignment = mkLiteral "vertical";
      };

      "listview" = {
        columns = 1;
        lines = 7;
        padding = mkLiteral "8 0";
        fixed-height = true;
        fixed-columns = true;
        fixed-lines = true;
        border = mkLiteral "0 10 6 10";
      };

      # INPUT BAR
      # ------------------------------------------------

      "entry" = {
        text-color = mkLiteral "#${palette.base05}";
        padding = mkLiteral "10 10 0 0";
        margin = mkLiteral "0 -2 0 0";
      };

      "inputbar" = {
        padding = mkLiteral "0 0 0";
        margin = mkLiteral "0 0 0 0";
      };

      "prompt" = {
        text-color = mkLiteral "#${palette.base0D}";
        padding = mkLiteral "10 6 0 10";
        margin = mkLiteral "0 -2 0 0";
      };

      # Mode Switcher
      # ------------------------------------------------

      "mode-switcher" = {
        border-color = mkLiteral "#${palette.base0F}";
        spacing = 0;
      };

      "button" = {
        padding = mkLiteral "10px";
        background-color = mkLiteral "@bg";
        text-color = mkLiteral "#${palette.base01}";
        vertical-align = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.5";
      };

      "button selected" = {
        background-color = mkLiteral "@bg";
        text-color = mkLiteral "#${palette.base0F}";
      };

      "message" = {
        background-color = mkLiteral "@bg";
        margin = mkLiteral "2px";
        padding = mkLiteral "2px";
        border-radius = mkLiteral "5px";
      };

      "textbox" = {
        padding = mkLiteral "6px";
        margin = mkLiteral "20px 0px 0px 20px";
        text-color = mkLiteral "#${palette.base0F}";
        background-color = mkLiteral "@bg";
      };
    };

    # theme = ''
    #   @theme "/dev/null"
    #
    #   * {
    #     bg: #${palette.base00};
    #     background-color: @bg;
    #   }
    #
    #   configuration {
    #     modi:		    "run,filebrowser,drun";
    #     show-icons:	    true;
    #     icon-theme:	    "Papirus";
    #     location:		    0;
    #     font:		    "JetBrains Nerd Font 16";
    #     drun-display-format:  "{icon} {name}";
    #     display-drun:	    "   Apps ";
    #     display-run:	    "   Run ";
    #     display-filebrowser:  "   File ";
    #   }
    #
    #   window {
    #     width: 45%;
    #     transparency: "real";
    #     orientation: vertical;
    #     border: 2px ;
    #     border-color: #${palette.base0F};
    #     border-radius: 10px;
    #   }
    #
    #   mainbox {
    #     children: [ inputbar, listview, mode-switcher ];
    #   }
    #
    #   // ELEMENT
    #   // -----------------------------------
    #
    #   element {
    #     padding: 8 14;
    #     text-color: #${palette.base05};
    #     border-radius: 5px;
    #   }
    #
    #   element selected {
    #     text-color: #${palette.base01};
    #     background-color: #${palette.base0C};
    #   }
    #
    #   element-text {
    #     background-color: inherit;
    #     text-color: inherit;
    #   }
    #
    #   element-icon {
    #     size: 24 px;
    #     background-color: inherit;
    #     padding: 0 6 0 0;
    #     alignment: vertical;
    #   }
    #
    #   listview {
    #     columns: 2;
    #     lines: 9;
    #     padding: 8 0;
    #     fixed-height: true;
    #     fixed-columns: true;
    #     fixed-lines: true;
    #     border: 0 10 6 10;
    #   }
    #
    #   // INPUT BAR
    #   //------------------------------------------------
    #
    #   entry {
    #     text-color: #${palette.base05};
    #     padding: 10 10 0 0;
    #     margin: 0 -2 0 0;
    #   }
    #
    #   inputbar {
    #     background-image: url("~/.config/rofi/rofi.jpg", width);
    #     padding: 180 0 0;
    #     margin: 0 0 0 0;
    #   }
    #
    #   prompt {
    #     text-color: #${palette.base0D};
    #     padding: 10 6 0 10;
    #     margin: 0 -2 0 0;
    #   }
    #
    #   // Mode Switcher
    #   //------------------------------------------------
    #
    #   mode-switcher {
    #     border-color:   #${palette.base0F};
    #     spacing:	      0;
    #   }
    #
    #   button {
    #     padding:	      10px;
    #     background-color: @bg;
    #     text-color:	      #${palette.base01};
    #     vertical-align:   0.5;
    #     horizontal-align: 0.5;
    #   }
    #
    #   button selected {
    #     background-color: @bg;
    #     text-color: #${palette.base0F};
    #   }
    #
    #   message {
    #     background-color: @bg;
    #     margin: 2px;
    #     padding: 2px;
    #     border-radius: 5px;
    #   }
    #
    #   textbox {
    #     padding: 6px;
    #     margin: 20px 0px 0px 20px;
    #     text-color: #${palette.base0F};
    #     background-color: @bg;
    #   }
    # '';
  };
}
