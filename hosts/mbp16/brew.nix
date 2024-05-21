{outputs, ...}: {
  imports = [
    # Add main homebrew module
    outputs.darwinModules.homebrew

    # Brews - See ../../modules/darwin/brews/default.nix

    # Casks - See ../../modules/darwin/casks/default.nix

    # Mas - See ../../modules/darwin/mas/default.nix
    outputs.darwinModules.mas
    {
      includeDevApps = true;
      includeNetworkingApps = true;
      includeOtherApps = true;
      includeProductivityApps = true;
      includeSocialApps = true;
      includeUtilitiesApps = true;
    }
  ];

  homebrew.onActivation.cleanup = "none"; # Don't break things on MBP16!
}
