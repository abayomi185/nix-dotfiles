{
  group_armDev = import ./groups/arm-dev.nix;
  group_mobileDev = import ./groups/mobile-dev.nix;
  group_awsDev = import ./groups/aws-dev.nix;
  group_azureDev = import ./groups/azure-dev.nix;

  docker = import ./docker.nix;
  imagemagick = import ./imagemagick.nix;
  llama-swap = import ./llama-swap.nix;
  sdl2 = import ./sdl2.nix;

  # Default brews that don't fit into a specific group
  homebrew.brews = ["mas" "python@3.12"];
}
