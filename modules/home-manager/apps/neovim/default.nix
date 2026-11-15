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
in {
  options.programs.neovim.astronvim = {
    dotfiles = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/nix-dotfiles";
      description = "Path to an editable nix-dotfiles clone; ~/.config/nvim links into it.";
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
  };
}
