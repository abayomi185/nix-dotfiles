{
  homebrew = {
    enable = true;

    onActivation = {
      # cleanup = "uninstall";
    };

    # global = {};

    taps = [
      "homebrew/bundle"

      # Azure
      "azure/functions"
    ];

    # brews = [];
    # casks = [];
    # masApps = {};
  };
}
