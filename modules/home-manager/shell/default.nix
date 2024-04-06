{
  # ZSH
  # zsh = import ./zsh;
  zsh = import ./zsh.nix;
  zsh_darwin = import ./zsh.darwin.nix;

  # Git
  git = import ./git.nix;

  # Starship
  starship = import ./starship.nix;
}
