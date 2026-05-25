{
  final,
  prev,
}: {
  bun = import ./bun.nix {
    inherit final prev;
  };
}
