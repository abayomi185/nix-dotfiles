{pkgs, ...}: {
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
        before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
        after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 180; # 3 minutes
          on-timeout = ''
            cat /sys/class/leds/tpacpi::kbd_backlight/brightness > /tmp/kbd_backlight
            echo 0 > /sys/class/leds/tpacpi::kbd_backlight/brightness
          ''; # turn off keyboard backlight
          on-resume = ''
            if [ -f /tmp/kbd_backlight ]; then
              cat /tmp/kbd_backlight > /sys/class/leds/tpacpi::kbd_backlight/brightness
            fi
          ''; # restore keyboard backlight
        }
        {
          timeout = 405; # 6 minutes 50 seconds
          on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
          on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r"; # monitor backlight restore
        }
        {
          timeout = 420; # 7 minutes
          on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off"; # screen off when timeout has passed
          on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on"; # screen on when activity is detected
        }
        {
          timeout = 430; # 7 minutes 10 seconds
          on-timeout = "${pkgs.systemd}/bin/loginctl lock-session"; # screen off when timeout has passed
        }
        {
          timeout = 600; # 10 minutes
          on-timeout = "${pkgs.systemd}/bin/systemctl suspend"; # screen off when timeout has passed
        }
      ];
    };
  };
}
