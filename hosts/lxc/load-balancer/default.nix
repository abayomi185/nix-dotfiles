{
  inputs,
  outputs,
  sops-nix,
}:
inputs.nixpkgs-stable.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit inputs outputs;
  };
  modules = [
    ./configuration.nix
    sops-nix.nixosModules.sops
  ];
}
