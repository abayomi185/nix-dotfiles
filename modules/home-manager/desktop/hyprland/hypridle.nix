{pkgs, ...}: {
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lockCmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
        beforeSleepCmd = "${pkgs.systemd}/bin/loginctl lock-session";
        afterSleepCmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      };

      listener = [
        # {
        #   timeout = 500; # 5 minutes
        #   # onTimeout = "";
        #   # onResume = "";
        # }
        {
          timeout = 405; # 6 minutes 50 seconds
          onTimeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
          onResume = "${pkgs.brightnessctl}/bin/brightnessctl -r"; # monitor backlight restore.
        }
        {
          timeout = 420; # 7 minutes
          onTimeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off"; # screen off when timeout has passed
          onResume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on"; # screen on when activity is detected
        }
        {
          timeout = 430; # 7 minutes 10 seconds
          onTimeout = ''${pkgs.hyprlock}/bin/hyprlock''; # screen off when timeout has passed
        }
        {
          timeout = 600; # 10 minutes
          onTimeout = "${pkgs.systemd}/bin/systemctl suspend"; # screen off when timeout has passed
        }
      ];
    };
  };
}
