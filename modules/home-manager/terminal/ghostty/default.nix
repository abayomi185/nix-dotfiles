{
  config,
  pkgs,
  ...
}: let
  ghostty-mock = pkgs.writeShellScriptBin "gostty-mock" ''
    true
  '';
in {
  # Ghostty is broken on macOS, so we mock it
  # Using homebrew cask instead
  programs.ghostty = {
    enable = true;
    package = ghostty-mock; # Set explicitly to null, as it is managed externally
    enableZshIntegration = true;
    installBatSyntax = false;
    # Consider using this key at a later point
    # settings = {
    #   theme = "dark:tokyonight,light:zenwritten_light";
    #   macos-titlebar-style = "hidden";
    #   macos-non-native-fullscreen = "true";
    #   macos-option-as-alt = "true";
    #   window-save-state = "always";
    #   keybind = [
    #     "alt+left=unbind"
    #     "alt+right=unbind"
    #     "alt+up=unbind"
    #     "alt+down=unbind"
    #   ];
    # };
  };

  # Set up symlink to wezterm.lua
  xdg.configFile."ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/modules/home-manager/terminal/ghostty/config";
}
