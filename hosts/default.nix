{
  self,
  inputs,
  ...
}:{
  # nix-darwin configurations
  # parts.darwinConfigurations.m1 = {
  #   system = "aarch64-darwin";
  #   stateVersion = 4;
  #   modules = [ ./m1/configuration.nix ];
  # };

  # NixOS configurations
  flake-parts.nixosConfigurations = {
    x280 = {
      system = "x86_64-linux";
      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      stateVersion = "23.11";

      modules = [ ./x280/configuration.nix ];
    };
  };
}
