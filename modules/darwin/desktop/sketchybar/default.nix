{ pkgs, ... }: {
  services.spacebar = {
    enable = true;

    extraPackages = with pkgs; [ ];

    config = builtins.readFile ./sketchybarrc;
  };
}
