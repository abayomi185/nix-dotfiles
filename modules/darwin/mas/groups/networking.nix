_: let
  networkingApps = {
    Tailscale = 1475387142;
    WireGuard = 1451685025;
  };
in {
  homebrew.masApps = networkingApps;
}
