{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    package = pkgs.unstable.neovim-unwrapped;
    defaultEditor = true;
    extraPackages = with pkgs; [
      # Global Lua packages
      lua-language-server
      stylua
      selene
      # Global Nix packages
      unstable.nil
      alejandra
      # Other Global
      prettierd
      taplo
    ];
  };
}
