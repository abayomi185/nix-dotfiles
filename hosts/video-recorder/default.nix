{
  inputs,
  outputs,
}:
inputs.nixpkgs-stable.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {inherit inputs outputs;};
  modules = [
    inputs.disko.nixosModules.disko
    ../nixos-anywhere/disk-config.nix
    ./configuration.nix
  ];
}
