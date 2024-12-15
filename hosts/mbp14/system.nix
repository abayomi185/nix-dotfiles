{
  system.defaults = {
    CustomUserPreferences = {};

    dock = {
      mineffect = "scale";
      minimize-to-application = true;
      mru-spaces = false;
      orientation = "bottom";
      tilesize = 45;
    };

    NSGlobalDomain = {
      AppleInterfaceStyleSwitchesAutomatically = true;
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = false;
      "com.apple.trackpad.scaling" = 1.0;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      # NSStatusItemSpacing = 12;
      # NSStatusItemSelectionPadding = 8;
    };

    screencapture = {
      type = "jpg";
      disable-shadow = true;
    };

    trackpad = {
      ActuationStrength = 0;
      FirstClickThreshold = 0;
      SecondClickThreshold = 0;
    };
  };
}
