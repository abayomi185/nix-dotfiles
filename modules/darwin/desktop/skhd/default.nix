{ pkgs, ... }:
{
  # Installed with Homebrew rather than Nix: `nix store optimise` gives store
  # binaries extra paths, and macOS permission checks sometimes land on an
  # ungranted one, dropping skhd's key events. A brew binary has one path.
  homebrew.taps = [ "koekeishiya/formulae" ];
  homebrew.brews = [ "koekeishiya/formulae/skhd" ];

  services.skhd = {
    enable = true;
    package = pkgs.runCommand "skhd-brew" { } ''
      mkdir -p $out/bin
      ln -s /opt/homebrew/bin/skhd $out/bin/skhd
    '';
    skhdConfig = builtins.readFile ./skhdrc;
  };
}
