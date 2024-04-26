{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
  ];
}
