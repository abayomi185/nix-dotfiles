{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      # Global Lua packages
      lua-language-server
      stylua
      selene
      # Global Nix packages
      nil
      alejandra
      # Other Global
      prettierd
      taplo
    ];
  };
}
