{outputs, ...}: {
  imports = [
    # Add main homebrew module
    outputs.darwinModules.homebrew

    # Brews - See ../../modules/darwin/brews/default.nix
    outputs.darwinModules.brews.llama-swap
    outputs.darwinModules.brews.group_mobileDev

    # Casks - See ../../modules/darwin/casks/default.nix
    outputs.darwinModules.casks.autodesk-fusion
    outputs.darwinModules.casks.brave
    outputs.darwinModules.casks.calibre
    outputs.darwinModules.casks.chatgpt
    outputs.darwinModules.casks.coconutbattery
    outputs.darwinModules.casks.figma
    outputs.darwinModules.casks.firefox
    outputs.darwinModules.casks.iina
    outputs.darwinModules.casks.karabiner-elements
    outputs.darwinModules.casks.kicad
    outputs.darwinModules.casks.notion
    outputs.darwinModules.casks.obs
    outputs.darwinModules.casks.obsidian
    outputs.darwinModules.casks.ollama-app
    outputs.darwinModules.casks.orca-slicer
    outputs.darwinModules.casks.raycast
    outputs.darwinModules.casks.serif-apps
    outputs.darwinModules.casks.spotify
    outputs.darwinModules.casks.sublime-text
    outputs.darwinModules.casks.xcodes-app
    outputs.darwinModules.casks.zen

    # Mas - See ../../modules/darwin/mas/default.nix
    outputs.darwinModules.mas.coreApps
    outputs.darwinModules.mas.devApps
    outputs.darwinModules.mas.networkingApps
    outputs.darwinModules.mas.otherApps
    outputs.darwinModules.mas.productivityApps
    outputs.darwinModules.mas.socialApps
    outputs.darwinModules.mas.utilitiesApps
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

  homebrew.onActivation.cleanup = "none"; # Don't break things on MBP16!
}
