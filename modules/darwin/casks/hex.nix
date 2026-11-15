{
  homebrew.taps = [
    {
      name = "anomalyco/tap";
      trusted = true;
    }
  ];
  homebrew.casks = ["anomalyco/tap/hex"];
}
