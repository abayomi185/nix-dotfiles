{outputs, ...}: {
  imports = [
    # Add main homebrew module
    outputs.darwinModules.homebrew

    # Brews - See ../../modules/darwin/brews/default.nix
    outputs.darwinModules.brews.group_mobileDev
    outputs.darwinModules.brews.group_awsDev
    outputs.darwinModules.brews.group_azureDev
    # outputs.darwinModules.brews.docker # Using OrbStack
    outputs.darwinModules.brews.sdl2

    # Casks - See ../../modules/darwin/casks/default.nix
    outputs.darwinModules.casks.autodesk-fusion
    outputs.darwinModules.casks.brave
    outputs.darwinModules.casks.bruno
    outputs.darwinModules.casks.calibre
    outputs.darwinModules.casks.coconutbattery
    outputs.darwinModules.casks.devtoys
    outputs.darwinModules.casks.figma
    outputs.darwinModules.casks.firefox
    outputs.darwinModules.casks.freecad
    outputs.darwinModules.casks.heroic
    outputs.darwinModules.casks.iina
    outputs.darwinModules.casks.kicad
    outputs.darwinModules.casks.notion
    outputs.darwinModules.casks.obs
    outputs.darwinModules.casks.obsidian
    outputs.darwinModules.casks.ollama
    outputs.darwinModules.casks.openscad
    outputs.darwinModules.casks.orca-slicer
    outputs.darwinModules.casks.orbstack
    outputs.darwinModules.casks.raycast
    outputs.darwinModules.casks.serif-apps
    outputs.darwinModules.casks.spotify
    outputs.darwinModules.casks.sublime-text
    outputs.darwinModules.casks.whisky
    outputs.darwinModules.casks.xcodes
    outputs.darwinModules.casks.zed

    # Mas - See ../../modules/darwin/mas/default.nix
    outputs.darwinModules.mas.coreApps
    outputs.darwinModules.mas.networkingApps
  ];

  homebrew.onActivation.cleanup = "uninstall";
}
