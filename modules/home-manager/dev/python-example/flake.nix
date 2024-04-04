{
  description = "A Python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.python3
            # pkgs.python3Packages.numpy
            # pkgs.python3Packages.pandas
            # Add any additional packages you need
          ];

          # Set any environment variables needed
          # ENV_VAR_NAME = "value";

          # Run any shell hook commands
          shellHook = ''
            echo "Welcome to the Python development environment!"
          '';
        };
      }
    );
}
