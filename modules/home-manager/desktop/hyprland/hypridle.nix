{
  services.hypridle = {
    enable = true;

    lockCmd = "pidof hyprlock || hyprlock";

    beforeSleepCmd = "loginctl lock-session";
    afterSleepCmd = "hyprctl dispatch dpms on";

    listeners = [
      # {
      #   timeout = 500; # 5 minutes
      #   # onTimeout = "";
      #   # onResume = "";
      # }
      {
        timeout = 420;
        onTimeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
        onResume = "hyprctl dispatch dpms on"; # screen on when activity is detected
      }
      {
        timeout = 430;
        onTimeout = "loginctl lock-session"; # screen off when timeout has passed
      }
      {
        timeout = 600;
        onTimeout = "loginctl lock-session"; # screen off when timeout has passed
      }
    ];
  };
}
