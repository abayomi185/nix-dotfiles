{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    package = pkgs.unstable.neovim-unwrapped;
    defaultEditor = true;
    withPython3 = true;
    withRuby = false;
    sideloadInitLua = true;
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
