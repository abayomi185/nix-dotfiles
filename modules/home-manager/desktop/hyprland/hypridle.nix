{
  programs.hypridle = {
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
        on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
        on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected
      }
      {
        timeout = 430;
        on-timeout = "loginctl lock-session"; # screen off when timeout has passed
      }
      {
        timeout = 600;
        on-timeout = "loginctl lock-session"; # screen off when timeout has passed
      }
    ];
  };
}
