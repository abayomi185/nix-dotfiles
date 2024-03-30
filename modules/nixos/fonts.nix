{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    ubuntu_font_family
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "JetBrainsMono" ]; })
  ];
}
