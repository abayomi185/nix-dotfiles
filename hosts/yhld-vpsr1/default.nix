{
  inputs,
  outputs,
}:
inputs.nixpkgs-stable.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {inherit inputs outputs;};
  modules = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager-stable.nixosModules.home-manager
    {
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {inherit inputs outputs;};
      home-manager.users.cloud = import ./home.nix;
    }
    ./configuration.nix
  ];
}
