{outputs, ...}: {
  imports = [
    # Add main homebrew module
    outputs.darwinModules.homebrew

    # Brews - See ../../modules/darwin/brews/default.nix
    outputs.darwinModules.brews.sdl2

    # Casks - See ../../modules/darwin/casks/default.nix
    outputs.darwinModules.casks.autodesk-fusion
    outputs.darwinModules.casks.brave
    outputs.darwinModules.casks.obsidian
    outputs.darwinModules.casks.orca-slicer
    outputs.darwinModules.casks.raycast
    outputs.darwinModules.casks.serif-apps

    # Mas - See ../../modules/darwin/mas/default.nix
    outputs.darwinModules.mas
  ];
}
