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

  options.programs.zsh.isDarwin = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether the system is Darwin.";
  };

  config = {
    # Common configuration for Zsh
    programs.zsh = {
      enable = lib.mkDefault true;

      enableCompletion = if config.programs.zsh.isDarwin then false else lib.mkDefault true;
      autosuggestion.enable = if config.programs.zsh.isDarwin then false else lib.mkDefault true;
      syntaxHighlighting.enable = if config.programs.zsh.isDarwin then false else lib.mkDefault true;

      history.size = lib.mkDefault 10000;

      # Define default shell aliases
      shellAliases = lib.mkMerge [
        (if config.programs.zsh.isDarwin then {} else {
          la = "ls -la";
          check = "nix flake check";
          update = lib.mkDefault "sudo nixos-rebuild switch";
          garbage = "sudo nix-collect-garbage --delete-older-than";
          develop = "nix develop -c $SHELL";
          dv = "eval $(direnv hook zsh)";
          batl = "bat --theme=base16";
        })
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
          # {
          #   name = "plugins/direnv";
          #   tags = ["from:oh-my-zsh"];
          # }
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
