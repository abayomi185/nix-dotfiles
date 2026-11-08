{ pkgs, ... }:
let
  stable = import ../stable-bin.nix {
    inherit pkgs;
    name = "skhd";
    src = pkgs.skhd;
  };
in
{
  system.activationScripts.preActivation.text = stable.activation;

  services.skhd = {
    enable = true;
    package = stable.package;
    skhdConfig = builtins.readFile ./skhdrc;
  };
}
