{
  inputs,
  outputs,
  pDiskDevice ? "/dev/sda",
}:
inputs.nixpkgs-stable.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {inherit inputs outputs pDiskDevice;};
  modules = [
    inputs.disko.nixosModules.disko
    ./configuration.nix
  ];
}
