{ pkgs, config, ... }: {
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 14;
        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = [
          "hyprland/window"
        ];
        modules-right = [
          "tray"
          "hyprland/language"
          "memory"
          "pulseaudio"
          "network"
          "battery"
          "clock"
        ];
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };
        "hyprland/window" = {
          format = "{title}";
          max-length = 50;
        };
        memory = {
          interval = 30;
          format = "{}% ";
          max-length = 10;
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [ "" "" "" "" "" ];
        };
        network = {
          format-wifi = "";
          format-ethernet = "{ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname} {signalStrength}%: {ipaddr}/{cidr}";
        };
        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };
        "hyprland/language" = {
          format = "{short} {variant}";
        };
      };
    };
    style = ''
      * {
        font-size: 14px;
        font-family: monospace;
      }

      window#waybar {
        background: #${config.colorScheme.colors.base01};
        color: #${config.colorScheme.colors.base05};
      }

      #workspaces,
      #memory,
      #tray,
      #language,
      #pulseaudio,
      #battery,
      #network,
      #clock {
        background: transparent;
      }

      #memory,
      #tray,
      #language,
      #pulseaudio,
      #network,
      #battery {
        padding-right: 24px;
      }
      #clock {
        padding-right: 10px;
      }

      #workspaces button {
        padding: 0 2px;
        color: #${config.colorScheme.colors.base04};
        border-radius: 0;
        border: 0;
        border-bottom: 2px solid transparent;
      }

      #workspaces button.active,
      #workspaces button:hover {
        color: #${config.colorScheme.colors.base05};
        background: #${config.colorScheme.colors.base01};
        border-color: #${config.colorScheme.colors.base05};
      }
    '';
  };
}
