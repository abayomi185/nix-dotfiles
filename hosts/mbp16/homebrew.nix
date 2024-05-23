{outputs, ...}: {
  imports = [
    # Add main homebrew module
    outputs.darwinModules.homebrew

    # Brews - See ../../modules/darwin/brews/default.nix

    # Casks - See ../../modules/darwin/casks/default.nix
    outputs.darwinModules.casks.ocenaudio

    # Mas - See ../../modules/darwin/mas/default.nix
    outputs.darwinModules.mas.coreApps
    outputs.darwinModules.mas.devApps
    outputs.darwinModules.mas.networkingApps
    outputs.darwinModules.mas.otherApps
    outputs.darwinModules.mas.productivityApps
    outputs.darwinModules.mas.socialApps
    outputs.darwinModules.mas.utilitiesApps
  ];

  homebrew.onActivation.cleanup = "none"; # Don't break things on MBP16!
}
