{
  coreApps = import ./core.nix;

  devApps = import ./dev.nix;
  networkingApps = import ./networking.nix;
  otherApps = import ./other.nix;
  productivityApps = import ./productivity.nix;
  socialApps = import ./social.nix;
  utilitiesApps = import ./utilities.nix;
}
