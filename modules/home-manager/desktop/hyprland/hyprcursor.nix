{pkgs, ...}: {
  home.packages = with pkgs; [hyprcursor];
  home.pointerCursor = {
    name = "phinger-cursors-dark";
    package = pkgs.phinger-cursors;
    size = 32;
    gtk.enable = true;
  };
}
