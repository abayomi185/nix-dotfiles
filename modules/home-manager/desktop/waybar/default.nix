{config, ...}: let
  palette = config.colorScheme.palette;
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
  fontSize = "12px";
  fontSizeLarge = "14px";
  topMargin = "5px";
  bottomMargin = "5px";
in {
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        height = 10;
        layer = "top";
        modules-left = ["custom/launcher" "cpu" "memory" "hyprland/workspaces"];
        modules-center = ["hyprland/window"];
        modules-right = ["mpris" "tray" "bluetooth" "pulseaudio" "backlight" "battery" "power-profiles-daemon" "clock"];

        "hyprland/workspaces" = {
          format = "{name}";
          all-outputs = true;
          on-click = "activate";
          format-icons = {
            active = " 󱎴";
            default = "󰍹";
          };
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
          };
        };

        "hyprland/language" = {
          format = "{short}";
        };

        "hyprland/window" = {
          max-length = 200;
          separate-outputs = true;
        };

        "tray" = {
          spacing = 10;
        };

        "clock" = {
          format = "{:%H:%M}";
          # format-alt = "{:%b %d %Y}";
          tooltip-format = "<big>{:%d %B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          on-click = "swaync-client -t";
        };

        "cpu" = {
          interval = 10;
          format = "  {usage:2}%";
          max-length = 10;
          on-click = "";
        };

        "memory" = {
          interval = 30;
          format = "󰵆 {used:0.1f}GB";
          max-length = 10;
          tooltip = false;
        };

        "temperature" = {
          interval = 10;
          format = " {temperatureC}°C";
          max-length = 10;
        };

        "backlight" = {
          device = "intel_backlight";
          format = "{icon}";
          tooltip = true;
          format-alt = "<small>{percent}%</small>";
          format-icons = ["󱩎" "󱩏" "󱩐" "󱩑" "󱩒" "󱩓" "󱩔" "󱩕" "󱩖" "󰛨"];
          on-scroll-up = "brightnessctl set 1%+";
          on-scroll-down = "brightnessctl set 1%-";
          smooth-scrolling-threshold = "2400";
          tooltip-format = "Brightness {percent}%";
        };

        "network" = {
          format-wifi = "{icon}";
          min-length = 10;
          fixed-width = 10;
          format-ethernet = "󰈀";
          format-disconnected = "󰤭";
          tooltip-format = "{essid}";
          interval = 1;
          format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
        };

        "bluetooth" = {
          format = "{icon}";
          format-alt = "bluetooth: {status}";
          interval = 30;
          format-icons = {
            enabled = "";
            disabled = "󰂲";
          };
          tooltip-format = "{status}";
        };

        "pulseaudio" = {
          format = "{icon}";
          format-muted = "󰖁";
          format-icons = {
            default = ["" "" "󰕾"];
          };
          on-click = "exec pavucontrol";
          on-scroll-up = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          tooltip-format = "Volume {volume}%";
        };

        "battery" = {
          bat = "BAT0";
          adapter = "ADP0";
          interval = 60;
          states = {
            warning = 20;
            critical = 10;
          };
          max-length = 20;
          format = "{icon}";
          format-warning = "{icon}";
          format-critical = "{icon}";
          format-charging = "<span font-family='Font Awesome 6 Free'></span>";
          format-plugged = "󰚥";
          format-notcharging = "󰚥";
          format-full = "󰂄";

          format-alt = "<small>{capacity}%</small> ";
          format-icons = ["󱊡" "󱊢" "󱊣"];
        };

        "power-profiles-daemon" = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          format-icons = {
            default = "";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };

        "custom/weather" = {
          exec = "nix-shell ~/.config/waybar/scripts/weather.py";
          restart-interval = 300;
          return-type = "json";
        };

        "mpris" = {
          format = "{player_icon} {title}";
          format-paused = " {status_icon} <i>{title}</i>";
          max-length = 50;
          player-icons = {
            default = "▶";
            mpv = "🎵";
            spotify = " ";
            brave = " ";
          };
          status-icons = {
            paused = "⏸ ";
          };
        };

        "custom/launcher" = {
          format = "󱄅";
          on-click = "rofi -show drun &";
        };
      };
    };

    style = ''
      * {
        /* `otf-font-awesome` is required to be installed for icons */
        font-family: JetBrainsMono Nerd Font, Iosevka Nerd Font ;
        font-size: ${fontSize};
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background-color: rgba(26, 27, 38, 0.5);
        color: #ffffff;
        transition-property: background-color;
        transition-duration: 0.5s;
      }

      window#waybar.hidden {
        opacity: 0.1;
      }

      #window {
        color: #64727d;
      }

      #clock,
      #temperature,
      #mpris,
      #cpu,
      #memory,
      #custom-media,
      #tray,
      #mode,
      #custom-lock,
      #workspaces,
      #idle_inhibitor,
      #custom-launcher,
      #custom-weather,
      #custom-weather.severe,
      #custom-weather.sunnyDay,
      #custom-weather.clearNight,
      #custom-weather.cloudyFoggyDay,
      #custom-weather.cloudyFoggyNight,
      #custom-weather.rainyDay,
      #custom-weather.rainyNight,
      #custom-weather.showyIcyDay,
      #custom-weather.snowyIcyNight,
      #custom-weather.default {
        color: #e5e5e5;
        border-radius: 6px;
        padding: 2px 10px;
        background-color: #252733;
        border-radius: 8px;
        font-size: ${fontSize};

        margin-left: 4px;
        margin-right: 4px;

        margin-top: ${topMargin};
        margin-bottom: ${bottomMargin};
      }

      #temperature {
        color: #7a95c9;
      }

      #cpu {
        color: #fb958b;
      }

      #memory {
        color: #a1c999;
      }

      #workspaces button {
        color: #7a95c9;
        box-shadow: inset 0 -3px transparent;

        padding-right: 3px;
        padding-left: 4px;

        margin-left: 0.1em;
        margin-right: 0em;
        transition: all 0.5s cubic-bezier(0.55, -0.68, 0.48, 1.68);
      }

      #workspaces button.active {
        color: #ecd3a0;
        padding-left: 1px;
        padding-right: 5px;
        font-family: Iosevka Nerd Font;
        font-weight: bold;
        font-size: ${fontSize};
        margin-left: 0em;
        margin-right: 0em;
        transition: all 0.5s cubic-bezier(0.55, -0.68, 0.48, 1.68);
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
        margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
        margin-right: 0;
      }

      #custom-launcher {
        margin-left: 12px;

        padding-right: 18px;
        padding-left: 14px;

        font-size: ${fontSizeLarge};

        color: #7a95c9;

        margin-top: ${topMargin};
        margin-bottom: ${bottomMargin};
      }

      #bluetooth,
      #backlight,
      #battery,
      #pulseaudio,
      #power-profiles-daemon
      #network {
        background-color: #252733;
        padding: 0em 2em;

        font-size: ${fontSize};

        padding-left: 7.5px;
        padding-right: 7.5px;

        padding-top: 3px;
        padding-bottom: 3px;

        margin-top: ${topMargin};
        margin-bottom: ${bottomMargin};
      }

      #pulseaudio {
        color: #81A1C1;
        font-size: ${fontSize};
      }

      #pulseaudio.muted {
        color: #fb958b;
        font-size: ${fontSize};
      }

      #backlight {
        color: #ecd3a0;
        padding-right: 5px;
        padding-left: 8px;
        font-size: ${fontSize};
      }

      #network {
        padding-left: 0.2em;
        color: #5E81AC;
        border-radius: 8px 0px 0px 8px;
        padding-left: 8px;
        padding-right: 8px;
        font-size: ${fontSize};
      }

      #network.disconnected {
        color: #fb958b;
      }

      #bluetooth {
        padding-left: 0.2em;
        color: #5E81AC;
        border-radius: 8px 0px 0px 8px;
        padding-left: 14px;
        font-size: ${fontSize};
      }

      #bluetooth.disconnected {
        color: #fb958b;
      }

      #battery {
        color: #8fbcbb;
        border-radius: 0px 8px 8px 0px;
        padding-right: 12px;
        padding-left: 12px;
        font-size: ${fontSize};
      }

      #battery.critical,
      #battery.warning,
      #battery.full,
      #battery.plugged {
        color: #8fbcbb;
        padding-left: 12px;
        padding-right: 12px;
        font-size: ${fontSize};
      }

      #battery.charging {
        font-size: ${fontSize};
        padding-right: 12px;
        padding-left: 12px;
      }

      #battery.full,
      #battery.plugged {
        font-size: ${fontSize};
        padding-right: 12px;
      }

      #power-profiles-daemon {
        padding-left: 0.2em;
        color: #5E81AC;
        border-radius: 8px 0px 0px 8px;
        padding-left: 10px;
        padding-right: 14px;
        font-size: ${fontSize};
      }

      @keyframes blink {
        to {
          background-color: rgba(30, 34, 42, 0.5);
          color: #abb2bf;
        }
      }

      #battery.warning {
        color: #ecd3a0;
      }

      #battery.critical:not(.charging) {
        color: #fb958b;
      }

      #custom-lock {
        color: #ecd3a0;
        padding: 0 15px 0 15px;
        margin-left: 7px;
        margin-top: ${topMargin};
        margin-bottom: ${bottomMargin};
      }

      #clock {
        color: #8a909e;
        font-family: Iosevka Nerd Font;
        font-weight: bold;
        margin-top: ${topMargin};
        margin-bottom: ${bottomMargin};
      }

      #language {
        color: #8a909e;
        font-family: Iosevka Nerd Font;
        font-weight: bold;
        border-radius : 8px 0 0 8px;
        margin-top: ${topMargin};
        margin-bottom: ${bottomMargin};
      }

      #custom-wallpaper {
        color: #8a909e;
        padding-right: 7;
        padding-left: 7;
      }
      #custom-wallpaper,
      #language {
        background-color: #252733;
        padding: 0em 2em;

        font-size: ${fontSize};

        padding-left: 7.5px;
        padding-right: 7.5px;

        padding-top: 3px;
        padding-bottom: 3px;

        margin-top: ${topMargin};
        margin-bottom: ${bottomMargin};
      }

      tooltip {
        font-family: Iosevka Nerd Font;
        border-radius: 15px;
        padding: 15px;
        background-color: #1f232b;
      }

      tooltip label {
        font-family: Iosevka Nerd Font;
        padding: 5px;
      }

      label:focus {
        background-color: #1f232b;
      }

      #tray {
        margin-right: 8px;
        margin-top: ${topMargin};
        margin-bottom: ${bottomMargin};
        font-size: ${fontSize};
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #eb4d4b;
      }

      #idle_inhibitor {
        background-color: #242933;
      }

      #idle_inhibitor.activated {
        background-color: #ecf0f1;
        color: #2d3436;
      }

      #mpris {
        color: #abb2bf;
      }

      #custom-weather {
        font-family: Iosevka Nerd Font;
        font-size: ${fontSize};
        color: #8a909e;
      }

      #custom-weather.severe {
        color: #eb937d;
      }

      #custom-weather.sunnyDay {
        color: #c2ca76;
      }

      #custom-weather.clearNight {
        color: #cad3f5;
      }

      #custom-weather.cloudyFoggyDay,
      #custom-weather.cloudyFoggyNight {
        color: #c2ddda;
      }

      #custom-weather.rainyDay,
      #custom-weather.rainyNight {
        color: #5aaca5;
      }

      #custom-weather.showyIcyDay,
      #custom-weather.snowyIcyNight {
        color: #d6e7e5;
      }

      #custom-weather.default {
        color: #dbd9d8;
      }
    '';
  };
}
