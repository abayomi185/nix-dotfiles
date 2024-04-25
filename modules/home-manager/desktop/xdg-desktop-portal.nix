{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;

    config = {
      common = {
        default = ["gtk"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
        "org.freedesktop.portal.FileChooser" = ["xdg-desktop-portal-gtk"];
      };
      hyprland.default = ["gtk" "hyprland"];
    };

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };
}
