{
  description = "Neovim (AstroNvim) Dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs =
          import nixpkgs
          {
            inherit system;
          };
      in
        with pkgs; {
          devShells.default = mkShell {
            buildInputs = [
              stylua
              lua-language-server
            ];
            shellHook = ''
              alias lua_ls="lua-language-server"
            '';
          };
        }
    );
}
