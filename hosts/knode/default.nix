{
  inputs,
  outputs,
  pClusterInterface ? "eth1",
  pDiskDevice ? "/dev/sda",
  pNodeId,
  pK3sRole ? "agent",
  pK3sClusterInit ? false,
  pK3sServerId ? "1",
}:
inputs.nixpkgs-stable.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit inputs outputs pClusterInterface pDiskDevice pNodeId pK3sRole pK3sServerId pK3sClusterInit;
  };
  modules = [
    inputs.disko.nixosModules.disko
    ./configuration.nix
    inputs.sops-nix.nixosModules.sops
  ];
}
