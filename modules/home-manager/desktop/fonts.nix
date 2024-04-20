{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    noto-fonts
    font-awesome
    ubuntu_font_family
    (nerdfonts.override {fonts = ["FiraCode" "DroidSansMono" "JetBrainsMono"];})
  ];

  # fontconfig = {
  #   defaultFonts = {
  #     serif = ["Ubuntu"];
  #     sansSerif = [ "Ubuntu"];
  #     monospace = ["JetBrainsMono"];
  #     emoticons = ["Noto Color Emoji"];
  #   };
  # };
}
