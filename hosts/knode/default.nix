{
  inputs,
  outputs,
  pNodeId,
  pK3sRole ? "agent",
  pK3sClusterInit ? false,
  pK3sServerId ? "1",
}:
inputs.nixpkgs-stable.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit inputs outputs pNodeId pK3sRole pK3sServerId pK3sClusterInit;
  };
  modules = [
    ./configuration.nix
    inputs.sops-nix.nixosModules.sops
  ];
}
