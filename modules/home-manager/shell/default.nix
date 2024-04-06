{
  # ZSH
  zsh = import ./zsh.nix; # With direnv
  # Direnv
  zsh_darwin = import ./zsh.darwin.nix;

  # Git
  git = import ./git.nix;

  # Starship
  starship = import ./starship.nix;
}
