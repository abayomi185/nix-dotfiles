{ self, config, pkgs, lib, ... }:
let
  # If laptop, include network/battery controls
  modules = [
    "network"
    "battery"
    "wireplumber"
    "pulseaudio#source"
    "bluetooth"
    "group/group-power"
  ];

  bluetoothToggle = pkgs.writeShellApplication {
    name = "bluetooth-toggle";
    runtimeInputs = with pkgs; [ gnugrep bluez ];
    text = ''
      if [[ "$(bluetoothctl show | grep -Po "Powered: \K(.+)$")" =~ no ]]; then
        bluetoothctl power on
        bluetoothctl discoverable on
      else
        bluetoothctl power off
      fi
    '';
  };

  theme = import "${self}/lib/theme" { inherit pkgs; };
  inherit ((import ../rofi/lib.nix { inherit lib; })) toRasi;
in
{
  programs.waybar = {
    enable = true;

    systemd = {
      enable = true;
    };

    settings = [{
      exclusive = true;
      position = "top";
      layer = "top";
      height = 18;
      width = null;
      passthrough = false;
      gtk-layer-shell = true;

      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" "idle_inhibitor" ];
      modules-right = modules;

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
          "1" = "";
          "2" = "";
          "3" = "󰙀";
          "4" = "";
          "5" = "";
          "6" = "";
          "7" = "";
        };
        on-click = "activate";
      };

      "network" = {
        format-wifi = "{essid} ";
        format-ethernet = "{ifname} ";
        format-disconnected = "";
        tooltip-format = "{ifname} / {essid} ({signalStrength}%) / {ipaddr}";
        max-length = 15;
        on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.networkmanager}/bin/nmtui";
      };

      "idle_inhibitor" = {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
      };

      "battery" = {
        states = {
          good = 95;
          warning = 20;
          critical = 10;
        };
        format = "{capacity}% {icon}";
        format-charging = "{capacity}% ";
        format-plugged = "";
        tooltip-format = "{time} ({capacity}%)";
        format-alt = "{time} {icon}";
        format-full = "";
        format-icons = [ "" "" "" "" "" ];
      };

      "group/group-power" = {
        orientation = "inherit";
        drawer = {
          transition-duration = 500;
          transition-left-to-right = false;
        };
        modules = [
          "custom/power"
          "custom/quit"
          "custom/lock"
          "custom/reboot"
        ];
      };

      "custom/quit" = {
        format = "󰗼";
        on-click = "${pkgs.hyprland}/bin/hyprctl dispatch exit";
        tooltip = false;
      };

      "custom/lock" = {
        format = "󰍁";
        on-click = "${lib.getExe pkgs.hyprlock}";
        tooltip = false;
      };

      "custom/reboot" = {
        format = "󰜉";
        on-click = "${pkgs.systemd}/bin/systemctl reboot";
        tooltip = false;
      };

      "custom/power" = {
        format = "";
        on-click = "${pkgs.systemd}/bin/systemctl poweroff";
        tooltip = false;
      };

      "clock" = { format = "{:%d %b %H:%M}"; };

      "wireplumber" = {
        format = "{volume}% {icon}";
        format-muted = "";
        on-click = "${lib.getExe pkgs.pavucontrol}";
        format-icons = [ "" "" "" ];
        tooltip-format = "{volume}% / {node_name}";
      };

      "pulseaudio#source" = {
        format = "{format_source}";
        format-source = "";
        format-source-muted = "";
        on-click = "${lib.getExe pkgs.pavucontrol}";
        tooltip-format = "{source_volume}% / {desc}";
      };

      "bluetooth" = {
        format-on = "";
        format-connected = "{device_alias} ";
        format-off = "";
        format-disabled = "";
        on-click-right = "${lib.getExe' pkgs.blueberry "blueberry"}";
        on-click = "${lib.getExe bluetoothToggle}";
      };
    }];

    # This is a bit of a hack. Rasi turns out to be basically CSS, and there is
    # a handy helper to convert nix -> rasi in the home-manager module for rofi,
    # so I'm using that here to render the stylesheet for waybar
    style = toRasi (import ./theme.nix { inherit config pkgs lib theme; }).theme;
  };

  # This is a hack to ensure that hyprctl ends up in the PATH for the waybar service on hyprland
  # systemd.user.services.waybar.Service.Environment = lib.mkForce
  #   "PATH=${lib.makeBinPath [pkgs."${desktop}"]}";
}
