{
  services.yabai = {
    enable = true;
    extraConfig = builtins.readFile ./yabairc;
    # extraConfig = builtins.readFile "${./.}/yabairc";
    # extraConfig = builtins.toFile "yabairc" (builtins.readFile ./yabairc);
  };
}
