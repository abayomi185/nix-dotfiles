{ config, pkgs, lib, ... }: {
  # Application Launcher
  programs.rofi = {
    enable = true;
    package = pkgs.stable.rofi-wayland;
    font = "Ubuntu Regular 14";
    terminal = lib.getExe pkgs.wezterm;
    cycle = true;
    location = "top";
    yoffset = 6;
    extraConfig = {
      modes = "run,drun,calc,emoji";
      icon-theme = config.gtk.iconTheme.name;
    };

    theme = ./gruvbox-dark-hard.rasi;

    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
      # (rofi-emoji.overrideAttrs {
      #   postFixup = ''
      #     chmod +x $out/share/rofi-emoji/clipboard-adapter.sh
      #     wrapProgram $out/share/rofi-emoji/clipboard-adapter.sh \
      #       --prefix PATH ':' \
      #         ${lib.makeBinPath (with pkgs; [ libnotify wl-clipboard wtype ])}
      #   '';
      # })
    ];
  };
}
