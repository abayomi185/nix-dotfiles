{
  description = "Learning Nix things";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils } @inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Define the system once
        name = "simple";
        src = ./.;
        # Use system here, bind to platform specific package
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = derivation {
          inherit system name src;
          builder = with pkgs; "${bash}/bin/bash";
          args = [ "-c" "echo foo > $out" ];
        };
      } # No semi colon here
    );
}
