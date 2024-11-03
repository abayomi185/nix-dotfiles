{
  inputs,
  pHostname,
  pK3sRole,
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
        inherit inputs outputs;
        pHostname = pHostname;
        pK3sRole = pK3sRole;
      };
      modules = [
        ./configuration.nix
        inputs.sops-nix.nixosModules.sops
      ];
    };
}
