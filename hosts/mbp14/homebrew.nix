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
    outputs.darwinModules.casks.chatgpt
    outputs.darwinModules.casks.coconutbattery
    outputs.darwinModules.casks.cursor
    outputs.darwinModules.casks.devtoys
    outputs.darwinModules.casks.figma
    outputs.darwinModules.casks.firefox
    outputs.darwinModules.casks.freecad
    outputs.darwinModules.casks.heroic
    outputs.darwinModules.casks.ice
    outputs.darwinModules.casks.iina
    outputs.darwinModules.casks.karabiner-elements
    outputs.darwinModules.casks.kicad
    outputs.darwinModules.casks.moonlight
    outputs.darwinModules.casks.notion
    outputs.darwinModules.casks.obs
    outputs.darwinModules.casks.obsidian
    outputs.darwinModules.casks.ollama
    outputs.darwinModules.casks.openscad
    outputs.darwinModules.casks.orbstack
    outputs.darwinModules.casks.orca-slicer
    outputs.darwinModules.casks.orion
    outputs.darwinModules.casks.raycast
    outputs.darwinModules.casks.serif-apps
    outputs.darwinModules.casks.spotify
    outputs.darwinModules.casks.steam
    outputs.darwinModules.casks.sublime-text
    outputs.darwinModules.casks.thinkorswim
    outputs.darwinModules.casks.virtualhere
    outputs.darwinModules.casks.whisky
    outputs.darwinModules.casks.xcodes
    outputs.darwinModules.casks.zed
    outputs.darwinModules.casks.zen-browser

    # Mas - See ../../modules/darwin/mas/default.nix
    outputs.darwinModules.mas.coreApps
    outputs.darwinModules.mas.networkingApps
  ];

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "yomi";
    autoMigrate = true;
    extraEnv = {
      HOMEBREW_NO_ANALYTICS = "1";
    };
  };

  homebrew.onActivation.cleanup = "uninstall";
}
