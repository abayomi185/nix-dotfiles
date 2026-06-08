{
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
