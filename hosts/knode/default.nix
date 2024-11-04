{
  inputs,
  pNodeId,
  pK3sRole,
  pK3sServerId,
  pK3sClusterInit,
  outputs,
  ...
}: {
  mkHost = {
    host,
    hardware,
    stateVersion,
    system,
    timezone,
    location,
    extraOverlays,
    extraModules,
  }:
    inputs.nixpkgs-stable.lib.nixosSystem
    {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs outputs pNodeId pK3sRole pK3sServerId pK3sClusterInit;
      };
      modules = [
        ./configuration.nix
        inputs.sops-nix.nixosModules.sops
      ];
    };
}
