{pkgs, ...}: let
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
    settings = {
      theme = "dark:tokyonight,light:tokyonight-day";
      macos-titlebar-style = "hidden";
    };
  };
}
