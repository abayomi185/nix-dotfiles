{
  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "uninstall";
    };

    # global = {};

    taps = [];

    brews = [];

    casks = [
      "affinity-designer"
      "affinity-photo"
      "affinity-publisher"
      "brave-browser"
      "discord"
      "obsidian"
    ];

    masApps = {
      # Xcode = 497799835;
      Wipr = 1320666476;
    };
  };
}
