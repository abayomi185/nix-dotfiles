{outputs, ...}: {
  imports = [
    # Add main homebrew module
    outputs.darwinModules.homebrew

    # Brews - See ../../modules/darwin/brews/default.nix

    # Casks - See ../../modules/darwin/casks/default.nix
    outputs.darwinModules.casks.brave
    outputs.darwinModules.casks.discord
    outputs.darwinModules.casks.obsidian
    outputs.darwinModules.casks.raycast
    outputs.darwinModules.casks.serif-apps

    # Mas - See ../../modules/darwin/mas/default.nix
    outputs.darwinModules.mas
  ];
}
