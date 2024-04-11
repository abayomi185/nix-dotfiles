{
  config,
  lib,
  ...
}: {
  # Darwin system configuration for Zsh
  programs.zsh = {
    enable = true;

    # enableCompletion = true; # Default
    # enableFzfCompletion = true;
    # enableFzfGit = true;
    # enableFzfHistory = true;
    # enableSyntaxHighlighting = true;

    # # zshrc equivalent
    # shellInit = lib.mkDefault "";
    #
    # # zshenv equivalent
    # interactiveShellInit = lib.mkDefault "";
    #
    # # zprofile equivalent
    # loginShellInit = lib.mkDefault "";
  };

  programs.direnv = {
    enable = lib.mkDefault true;
    nix-direnv.enable = true;
  };
}
