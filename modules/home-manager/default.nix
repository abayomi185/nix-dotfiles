# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  # my-module = import ./my-module.nix;

  # Apps
  apps = import ./apps;

  # Browsers
  browsers = import ./browsers;

  # Desktop
  desktop = import ./desktop;

  # Dev
  dev = import ./dev;

  # Monitoring
  monitoring = import ./monitoring;

  # Music
  music = import ./music;

  # Shell
  shell = import ./shell;

  # Terminal
  terminal = import ./terminal;

  # Utils
  utils = import ./utils;
}
