{
  services.hypridle = {
    enable = true;

    lockCmd = "pidof hyprlock || hyprlock";

    beforeSleepCmd = "pidof hyprlock || hyprlock";
    afterSleepCmd = "hyprctl dispatch dpms on";

    listeners = [
      # {
      #   timeout = 500; # 5 minutes
      #   # onTimeout = "";
      #   # onResume = "";
      # }
      {
        timeout = 405; # 6 minutes 50 seconds
        onTimeout = "brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
        onResume = "brightnessctl -r"; # monitor backlight restore.
      }
      {
        timeout = 420; # 7 minutes
        onTimeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
        onResume = "hyprctl dispatch dpms on"; # screen on when activity is detected
      }
      {
        timeout = 430; # 7 minutes 10 seconds
        onTimeout = "hyprlock"; # screen off when timeout has passed
      }
      {
        timeout = 600; # 10 minutes
        onTimeout = "systemctl suspend"; # screen off when timeout has passed
      }
    ];
  };
}
