{pkgs, ...}: {
  home.packages = with pkgs; [
    # prtsc # check https://github.com/spikespaz/dotfiles
    iwgtk
    libnotify
    lxqt.pavucontrol-qt
    wireplumber
    brightnessctl
  ];
}
