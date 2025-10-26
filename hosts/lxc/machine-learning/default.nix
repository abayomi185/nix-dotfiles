{
  inputs,
  outputs,
}:
inputs.nixpkgs-unstable.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit inputs outputs;
  };
  modules = [
    ./configuration.nix
  ];
}
