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
          batl = "bat --theme=OneHalfLight";
          check = "nix flake check";
          develop = "nix develop -c $SHELL";
          dv = "eval $(direnv hook zsh)";
          garbage = "sudo nix-collect-garbage --delete-older-than";
          gc = "nix-collect-garbage";
          la = "ls -la";
          lg = "lazygit";
          update = lib.mkDefault "sudo nixos-rebuild switch";
          vim = "nvim";
          ns = "NIXPKGS_ALLOW_UNFREE=1 nix-shell -p";
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
