{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = true;
    withRuby = false;
    extraPackages = with pkgs; [
      # Global Lua packages
      lua-language-server
      stylua
      selene
      # Global Nix packages
      alejandra
      deadnix
      nil
      statix
      # Other Global
      prettierd
      taplo
    ];
  };
}
