{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # prtsc # check https://github.com/spikespaz/dotfiles

    # Screenshot
    inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
    drawing

    gnome.gnome-tweaks
    gnome.dconf-editor

    brightnessctl
    killall
    libnotify
    pavucontrol
    networkmanagerapplet
    nwg-look
    wireplumber
  ];
}
