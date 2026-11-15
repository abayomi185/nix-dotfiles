# Neovim with the AstroNvim config in ./config.
# ~/.config/nvim symlinks to ./config inside an editable nix-dotfiles checkout,
# so edits and lazy-lock.json updates land in git (same pattern as wezterm/zellij).
# Self-contained (no `outputs`/overlays), so other flakes can import it by path.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.neovim.astronvim;
  git = lib.getExe pkgs.git;
  dotfiles = lib.escapeShellArg cfg.dotfiles;
  nvimDir = lib.escapeShellArg "${config.xdg.configHome}/nvim";
in {
  options.programs.neovim.astronvim = {
    dotfiles = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/nix-dotfiles";
      description = "Editable nix-dotfiles checkout; cloned on activation if missing.";
    };
    profile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "work";
      description = "Sets NVIM_PROFILE, which the config uses to enable machine-specific plugins.";
    };
  };

  config = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      withPython3 = true;
      withRuby = false;
      sideloadInitLua = true; # don't write ~/.config/nvim/init.lua; that dir is the checkout
      extraPackages = with pkgs; [
        # Lua
        lua-language-server
        stylua
        selene
        # Nix
        alejandra
        deadnix
        nil
        statix
        # Other
        prettierd
        taplo
      ];
    };

    xdg.configFile."nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.dotfiles}/modules/home-manager/apps/neovim/config";

    home.sessionVariables = lib.mkIf (cfg.profile != null) {NVIM_PROFILE = cfg.profile;};

    home.activation = {
      # One-off: move a pre-existing ~/.config/nvim directory aside so the symlink can replace it
      astronvimBackup = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
        if [ -d ${nvimDir} ] && [ ! -L ${nvimDir} ]; then
          backup=${nvimDir}.bak-$(date +%Y%m%d%H%M%S)
          noteEcho "Moving "${nvimDir}" to $backup"
          run mv ${nvimDir} "$backup"
        fi
      '';
      # Fresh machine: clone over https (no ssh agent needed), push over ssh
      astronvimClone = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ! -e ${dotfiles} ]; then
          if run ${git} clone https://github.com/abayomi185/nix-dotfiles.git ${dotfiles}; then
            run ${git} -C ${dotfiles} remote set-url --push origin git@github.com:abayomi185/nix-dotfiles.git
          else
            warnEcho "Could not clone nix-dotfiles; rerun activation once online"
          fi
        fi
      '';
    };
  };
}
