{
  services.skhd = {
    enable = true;
    skhdConfig = builtins.readFile ./skhdrc;
  };
}
