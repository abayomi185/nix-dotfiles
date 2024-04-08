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
          update = "sudo nixos-rebuild switch";
          garbage = "sudo nix-collect-garbage --delete-older-than";
          develop = "nix develop -c $SHELL";
        }
        config.programs.zsh.extendedShellAliases
      ];

      # zshrc equivalent
      initExtra = lib.mkDefault "";

      # zshenv equivalent
      envExtra = lib.mkDefault "";

      # zprofile equivalent
      profileExtra = lib.mkDefault "";

      zplug = {
        enable = lib.mkDefault true;
        plugins = [
          {
            name = "plugins/git";
            tags = ["from:oh-my-zsh"];
          }
          {
            name = "plugins/vi-mode";
            tags = ["from:oh-my-zsh"];
          }
        ];
      };
    };

    programs.direnv = {
      enable = lib.mkDefault true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
