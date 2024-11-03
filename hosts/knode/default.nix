{
  inputs,
  pHostname,
  pK3sRole,
  pK3sServerAddr,
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
        inherit inputs outputs pHostname pK3sRole pK3sServerAddr pK3sClusterInit;
      };
      modules = [
        ./configuration.nix
        inputs.sops-nix.nixosModules.sops
      ];
    };
}
