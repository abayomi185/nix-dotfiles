{pkgs, ...}: {
  home.packages = with pkgs; [
    # prtsc # check https://github.com/spikespaz/dotfiles

    brightnessctl
    killall
    libnotify
    pavucontrol
    networkmanagerapplet
    nwg-look
    wireplumber
  ];
}
