{pkgs, ...}: {
  # xdg.mimeApps = {
  #   enable = true;
  #   defaultApplications = {
  #     "application/pdf" = ["brave-browser.desktop"];
  #     "x-scheme-handler/http" = ["brave-browser.desktop"];
  #     "x-scheme-handler/https" = ["brave-browser.desktop"];
  #     "text/html" = ["brave-browser.desktop"];
  #   };
  # };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;

    config = {
      common = {
        default = ["gtk"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
        "org.freedesktop.impl.portal.FileChooser" = ["nemo"];
      };
      hyprland.default = ["gtk" "hyprland"];
    };

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };
}
