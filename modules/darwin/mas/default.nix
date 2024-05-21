{
  lib,
  includeDevApps ? false,
  includeNetworkingApps ? false,
  includeOtherApps ? false,
  includeProductivityApps ? false,
  includeSocialApps ? false,
  includeUtilitiesApps ? false,
  ...
}: let
  coreApps = {
    DaisyDisk = 411643860;
    HomeAssistant = 1099568401;
    Wipr = 1320666476;
  };

  devApps = {
    # Xcode = 497799835;
    Transporter = 1450874784;
  };

  networkingApps = {
    Tailscale = 1475387142;
    WireGuard = 1451685025;
  };

  otherApps = {
    MacTracker = 311421597;
    PoolsuiteFM = 1514817810;
  };

  productivityApps = {
    ApplePages = 409201541;
    AppleNumbers = 409203825;
    AppleKeynote = 409183694;
    # XnConvert = 436203431;
  };

  socialApps = {
    Twitter = 1482454543;
  };

  utilitiesApps = {
    AppleConfigurator = 1037126344;
    # Cuprum = 1088670425;
    HiddenBar = 1452453066;
    # TheUnarchiver = 425424353;
  };

  masApps =
    lib.optionalAttrs includeDevApps devApps
    // lib.optionalAttrs includeNetworkingApps networkingApps
    // lib.optionalAttrs includeOtherApps otherApps
    // lib.optionalAttrs includeProductivityApps productivityApps
    // lib.optionalAttrs includeSocialApps socialApps
    // lib.optionalAttrs includeUtilitiesApps utilitiesApps
    // coreApps;
in {
  homebrew.masApps = masApps;
}
