{pkgs, ...}: {
  imports = [./neovim];
  programs.neovim.package = pkgs.unstable.neovim-unwrapped;
}
