# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here

  # Uncategorized
  clipboard = import ./clipboard.nix;
  fonts = import ./fonts.nix;

  # Networking
  networking = import ./networking;

  # Apps
  apps = import ./apps;
}
