# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  # my-module = import ./my-module.nix;

  # Apps
  apps = import ./apps;

  # Shell
  shell = import ./shell;

  # Terminal
  terminal = import ./terminal;

  # Desktop
  desktop = import ./desktop;

  # Browsers
  browsers = import ./browsers;

  # Music
  music = import ./music;

  # Dev
  dev = import ./dev;
}
