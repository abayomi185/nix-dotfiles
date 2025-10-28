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
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.ml = ./home.nix;
    }
  ];
}
