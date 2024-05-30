{
  homebrew = {
    enable = true;

    onActivation = {
      # cleanup = "uninstall";
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
