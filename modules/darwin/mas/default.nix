{
  coreApps = import ./groups/core.nix;

  # Grouped by category
  devApps = import ./groups/dev.nix;
  networkingApps = import ./groups/networking.nix;
  otherApps = import ./groups/other.nix;
  productivityApps = import ./groups/productivity.nix;
  socialApps = import ./groups/social.nix;
  utilitiesApps = import ./groups/utilities.nix;

  # Individual apps
  overcast = import ./overcast.nix;
}
