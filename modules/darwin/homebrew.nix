{
  homebrew = {
    enable = true;

    onActivation = {
      # cleanup = "uninstall"; # Default is none
    };

    # global = {};

    taps = [
      "homebrew/bundle"
    ];

    # brews = [];
    # casks = [];
    # masApps = {};
  };
}
