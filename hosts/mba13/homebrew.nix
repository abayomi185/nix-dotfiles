{outputs, ...}: {
  imports = [
    # Add main homebrew module
    outputs.darwinModules.homebrew

    # Brews - See ../../modules/darwin/brews/default.nix
    outputs.darwinModules.brews.group_mobileDev
    outputs.darwinModules.brews.docker
    outputs.darwinModules.brews.sdl2

    # Casks - See ../../modules/darwin/casks/default.nix
    outputs.darwinModules.casks.autodesk-fusion
    outputs.darwinModules.casks.brave
    outputs.darwinModules.casks.calibre
    outputs.darwinModules.casks.coconutbattery
    outputs.darwinModules.casks.notion
    outputs.darwinModules.casks.obs
    outputs.darwinModules.casks.obsidian
    outputs.darwinModules.casks.orca-slicer
    outputs.darwinModules.casks.raycast
    outputs.darwinModules.casks.serif-apps
    outputs.darwinModules.casks.xcodes

    # Mas - See ../../modules/darwin/mas/default.nix
    outputs.darwinModules.mas.coreApps
    outputs.darwinModules.mas.networkingApps
  ];
}
