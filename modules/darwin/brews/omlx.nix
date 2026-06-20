{

# NOTE: Homebrew 4.x refuses to load formulae from untrusted taps. After
# the first activation on a new machine, run:
#   brew trust jundot/omlx
# (without sudo; the tap is user-level). This is a one-time step; the trust
# persists across rebuilds. The pinned nix-darwin here predates
# homebrew.taps.*.trusted, so it can't be declared in this file.
  homebrew.taps = [
    {
      name = "jundot/omlx";
      clone_target = "https://github.com/jundot/omlx";
    }
  ];
  homebrew.brews = [
    "omlx"
  ];
}
