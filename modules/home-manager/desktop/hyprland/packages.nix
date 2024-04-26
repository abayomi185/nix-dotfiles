{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # prtsc # check https://github.com/spikespaz/dotfiles

    inputs.hyprland-contrib.packages.${pkgs.system}.grimblast

    brightnessctl
    killall
    libnotify
    pavucontrol
    networkmanagerapplet
    nwg-look
    wireplumber
  ];
}
