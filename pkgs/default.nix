# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  # example = pkgs.callPackage ./example { };

  # wezterm-nightly = let
  #   callPackage =
  #     if pkgs.stdenv.isDarwin
  #     then pkgs.darwin.apple_sdk_11_0.callPackage
  #     else pkgs.callPackage;
  # in
  #   callPackage ./wezterm-nightly {};

  firefly-iii-data-importer = pkgs.callPackage ./firefly-iii-data-importer {};
}
