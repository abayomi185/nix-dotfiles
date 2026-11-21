{pkgs, ...}: let
  # macOS keys Accessibility/Input grants to a binary's real path. Brew's
  # /opt/homebrew/bin/skhd is a symlink into Cellar/skhd/<version>/, so each
  # upgrade looks like a new app and re-prompts. Run a copy at a fixed path.
  bin = "/usr/local/libexec/skhd";
in {
  # Installed with Homebrew rather than Nix: `nix store optimise` gives store
  # binaries extra paths, and macOS permission checks sometimes land on an
  # ungranted one, dropping skhd's key events. A brew binary has one path.
  homebrew.taps = [
    {
      name = "asmvik/formulae"; # koekeishiya/formulae was renamed
      trusted = true;
    }
  ];
  homebrew.brews = ["asmvik/formulae/skhd"];

  # Runs after the homebrew step. Restart only when the binary changed.
  system.activationScripts.postActivation.text = ''
    if ! cmp -s /opt/homebrew/bin/skhd ${bin}; then
      mkdir -p /usr/local/libexec
      cp /opt/homebrew/bin/skhd ${bin}.new
      mv -f ${bin}.new ${bin}
      pkill -x skhd || true
    fi
  '';

  services.skhd = {
    enable = true;
    package = pkgs.runCommand "skhd-brew" {} ''
      mkdir -p $out/bin
      ln -s ${bin} $out/bin/skhd
    '';
    skhdConfig = builtins.readFile ./skhdrc;
  };
}
