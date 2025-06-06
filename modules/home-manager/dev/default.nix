{
  cargo-bins = import ./cargo-bins.nix;
  devenv = import ./devenv.nix;
  github = import ./github.nix;
  go = import ./go.nix;
  kubectl = import ./kubectl.nix;
  lua = import ./lua.nix;
  nodejs = import ./nodejs.nix;
  python = import ./python.nix;
  rust = import ./rust.nix;
  turso = import ./turso.nix;
  xcodes = import ./xcodes.nix; # For managing Xcode versions
  zig = import ./zig.nix;
}
