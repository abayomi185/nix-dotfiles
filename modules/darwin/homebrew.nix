{
  homebrew = {
    enable = true;

    onActivation = {
      # cleanup = "uninstall"; # Default is none
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
