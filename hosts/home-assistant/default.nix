{
  inputs,
  outputs,
}:
# Unstable: HA cannot downgrade, and stable lags the running HAOS release.
inputs.nixpkgs-unstable.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {inherit inputs outputs;};
  modules = [
    inputs.disko.nixosModules.disko
    ../nixos-anywhere/disk-config.nix
    ./configuration.nix
  ];
}
