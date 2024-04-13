{
  config,
  lib,
  ...
}: {
  options.programs.zsh.extendedShellAliases = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    description = "Shell aliases for Zsh.";
  };

  config = {
    # Common configuration for Zsh
    programs.zsh = {
      enable = lib.mkDefault true;

      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history.size = lib.mkDefault 10000;

      # Define default shell aliases
      shellAliases = lib.mkMerge [
        {
          la = "ls -la";
          check = "nix flake check";
          update = lib.mkDefault "sudo nixos-rebuild switch";
          garbage = "sudo nix-collect-garbage --delete-older-than";
          develop = "nix develop -c $SHELL";
          dv = "eval $(direnv hook zsh)";
          batl = "bat --theme=OneHalfLight";
        }
        config.programs.zsh.extendedShellAliases
      ];

      # zshrc equivalent
      initExtra = lib.mkDefault "";

      # zshenv equivalent
      envExtra = lib.mkDefault "";

      # zprofile equivalent
      profileExtra = lib.mkDefault "";

      oh-my-zsh = {
        enable = lib.mkDefault true;
        plugins = [
          "git"
          "vi-mode"
          # "direnv"
        ];
      };
    };

    programs.direnv = {
      enable = lib.mkDefault false;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
