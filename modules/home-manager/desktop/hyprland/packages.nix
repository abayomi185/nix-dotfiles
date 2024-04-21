{pkgs, ...}: {
  home.packages = with pkgs; [
    # prtsc # check https://github.com/spikespaz/dotfiles
    networkmanagerapplet
    libnotify
    lxqt.pavucontrol-qt
    wireplumber
    brightnessctl
    killall
  ];
}
